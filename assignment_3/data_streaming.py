"""
Assignment 3 - Data Stream Processing
Course: Information Systems and Data Analysis - TU Berlin

Scenario: Intelligent traffic control on a 3-lane highway using real-time data,
built using the ISDA Streaming API (a custom course framework, not a public library).

Input stream element structure (TimedStream):
    (lane, velocity, type, brand)

    lane:     highway lane, numbered 1-3
    velocity: measured speed in km/h
    type:     vehicle type ("lkw" = truck, "pkw" = car)
    brand:    vehicle brand (e.g. "Volvo")

Synopsis parameters used throughout (required by the assignment):
    Reservoir Sample: sample_size = 100
    Bloom Filter:     n_bits = 12, n_hash_functions = 3
    Count-Min Sketch: width = 40, depth = 3

Result: 10/10 points
"""


# ============================================================
# Query 1 (1pt) - Rolling max velocity of cars (pkw) per lane
# ============================================================
# Output element structure per lane: rolling_pkw_max_velocity

def get_lane(x):
    return x[0]


def get_velocity(x):
    return x[1]


def get_is_pkw(x):
    if x[2] == "pkw":
        return True
    return False


def pkw_max_velocity_per_lane(input_stream: TimedStream) -> Any:
    pkw_stream = input_stream.filter(get_is_pkw)
    keyed_stream = pkw_stream.key_by(get_lane)
    max_velocity_per_lane = keyed_stream.map(get_velocity).reduce(max)

    return max_velocity_per_lane


# ============================================================
# Query 2 (1pt) - Truck (lkw) ratio per lane (lane 1 and 2 only)
# ============================================================
# Output element structure per lane: (ratio_in_percent)

def is_third_lane(x):
    if x[0] == 3:
        return False
    return True


def get_type(x):
    return x[2]


def give_value(x):
    if x == 'lkw':
        return (1, 1)
    return (1, 0)


def sum(value1, value2):
    return (value1[0] + value2[0], value1[1] + value2[1])


def ratio(x):
    return float(round(100 * x[1] / x[0], 2))


def lkw_ratio(input_stream: TimedStream) -> Any:
    type_stream = input_stream.filter(is_third_lane).key_by(get_lane).map(get_type)

    output_stream = type_stream.map(give_value).reduce(sum).map(ratio)
    return output_stream


# ============================================================
# Query 3 (2pt) - Min of mean velocities (10 cars) on lane 2,
#                 over the last 100 cars, updated every 50 cars
# ============================================================
# Output element structure: (min_mean_velocity)

def is_second_lane(x):
    if x[0] == 2:
        return True
    return False


def lane_2_min_mean_velocity_100_cars(input_stream: TimedStream) -> Any:
    window_stream = input_stream.filter(is_second_lane).map(lambda x: x[1])
    output_stream = (
        window_stream
        .tumbling_tuple_window(10).aggregate('mean').map(lambda x: x[0])
        .sliding_window(10, 5).aggregate('min').map(lambda x: x[0])
    )
    return output_stream


# ============================================================
# Query 4 (2pt) - Traffic density (vehicles per km), updated
#                 every 60 minutes
# ============================================================
# traffic_density = traffic_intensity (vehicles/hour) / avg_velocity
# Output element structure: (traffic_density, window_start, window_end)

def add(x):
    count = 0
    result = 0
    for item in x:
        result += item
        count += 1
    avg_velo = result / count
    return count / avg_velo


def traffic_density(input_stream: TimedStream) -> Any:
    return input_stream.map(lambda x: x[1]).tumbling_time_window(3600).apply(add)


# ============================================================
# Query 5 (2pt) - Approximate count of pkw per brand and lane,
#                 per hour, updated every 30 minutes
#                 (Count-Min Sketch, since brand/lane combos
#                 are unbounded)
# ============================================================
# Identifier format: "brand_lane", e.g. ("VW", 2.0) -> "VW_2"
#
# Output element structure approx_brand_count: (approx_data_structure, window_start, window_end)
# Output element structure query_brand_and_lane: (approx_n_cars, window_start, window_end)

def is_pkw(x):
    if x[2] == 'pkw':
        return True
    return False


def get_string(x):
    return (x[3] + '_' + str(int(x[0])))


def get_tupel(x):
    return_tupel = ()
    for item in x:
        return_tupel += (item,)
    return return_tupel


def count(x, brand, lane):
    cm = CountMinSketch(40, 3)
    for item in x[0]:
        cm.update(item)
    result = cm.query(brand + '_' + str(int(lane)))
    return (result, x[1], x[2])


def approx_brand_count(input_stream: TimedStream) -> DataStream:
    return (
        input_stream
        .filter(is_pkw)
        .map(get_string)
        .sliding_time_window(3600, 1800)
        .apply(get_tupel)
    )


def query_brand_and_lane(approx_brand_count: DataStream, brand: str, lane: int) -> Any:
    return approx_brand_count.map(lambda x: count(x, brand, lane))


# ============================================================
# Query 6 (2pt) - Reservoir sample of all vehicles above the
#                 130 km/h speed limit, updated every 60 minutes
#                 (Reservoir Sample, since the set of recorded
#                 vehicles is unbounded)
# ============================================================
# Output element structure sample_cars_above_130: (sample_data_structure, window_start, window_end)
# Output element structure query_brand_above_130: (percentage, window_start, window_end)

def is_above_130(x):
    if x[1] > 130:
        return True
    return False


def reservoir_sample(x):
    rs = ReservoirSample(100)
    for item in x:
        rs.update(item)
    return_tupel = ()
    for item in rs.get_sample():
        return_tupel += (item,)
    return return_tupel


def ratio(x, brand):
    count = 0
    for item in x[0]:
        if item == brand:
            count += 1
    return (count / 1, x[1], x[2])


def sample_cars_above_130(input_stream: TimedStream) -> DataStream:
    return (
        input_stream
        .filter(is_above_130)
        .map(lambda x: x[3])
        .landmark_time_window(3600)
        .apply(reservoir_sample)
    )


def query_brand_above_130(sample_cars_above_130_output: DataStream, brand: str) -> Any:
    return sample_cars_above_130_output.map(lambda x: ratio(x, brand))