# Assignment 3 – Data Stream Processing

## Task Description

Implementation of dataflow pipelines for intelligent highway traffic control using real-time data, as part of a fictional role as a data analyst at a (German) federal ministry of digital affairs and transport.

The pipelines were implemented using the **ISDA Streaming API**, a custom streaming framework provided by the course (not a public/standard Python library — classes like `TimedStream`, `DataStream`, `CountMinSketch`, and `ReservoirSample`, along with stream operations like `.filter()`, `.map()`, `.key_by()`, `.reduce()`, `.tumbling_time_window()`, `.sliding_time_window()`, and `.landmark_time_window()`, are part of this framework and assumed to be pre-imported in the grading environment).

## Input Stream

A `TimedStream` from a traffic monitoring system on a 3-lane highway. Each element represents a detected vehicle as a tuple:

```python
(lane, velocity, type, brand)
```

| Field | Description |
|---|---|
| `lane` | Highway lane, numbered 1–3 |
| `velocity` | Measured speed in km/h |
| `type` | Vehicle type (`"lkw"` = truck, `"pkw"` = car) |
| `brand` | Vehicle brand (e.g. `"Volvo"`) |

## Synopsis Parameters

As required by the assignment, the following fixed parameters were used for all probabilistic data structures:

| Structure | Parameters |
|---|---|
| Reservoir Sample | `sample_size = 100` |
| Bloom Filter | `n_bits = 12`, `n_hash_functions = 3` |
| Count-Min Sketch | `width = 40`, `depth = 3` |

## Queries Overview

| # | Function(s) | Description | Points |
|---|---|---|---|
| 1 | `pkw_max_velocity_per_lane` | Rolling maximum velocity of cars per lane | 1 |
| 2 | `lkw_ratio` | Truck ratio (%) per lane, lanes 1 & 2 only | 1 |
| 3 | `lane_2_min_mean_velocity_100_cars` | Min of mean velocities (10 cars) on lane 2, over the last 100 cars, updated every 50 cars | 2 |
| 4 | `traffic_density` | Vehicles per km, derived from vehicles/hour and average velocity, updated hourly | 2 |
| 5 | `approx_brand_count` / `query_brand_and_lane` | Approximate car count per brand & lane per hour via **Count-Min Sketch**, updated every 30 min | 2 |
| 6 | `sample_cars_above_130` / `query_brand_above_130` | Reservoir sample of vehicles above 130 km/h, brand share per window via **Reservoir Sampling**, updated hourly | 2 |

## Notable Design Decisions

- **Count-Min Sketch** (Query 5) was chosen because the combination of brand × lane is unbounded — a data structure that grows with the number of distinct brands would violate the assignment's memory constraint.
- **Reservoir Sampling** (Query 6) was chosen for the same reason: the number of vehicles above 130 km/h since the start of the stream is unbounded, so a fixed-size sample is required instead of storing every vehicle.
- Both parametrized queries (5 and 6) use **first-order functions defined inside the pipeline function body** to allow filtering/querying by an arbitrary `brand` and `lane` parameter at call time, as suggested by the assignment hint.
- Query 5 encodes the brand/lane combination as a string identifier (`"brand_lane"`), explicitly casting lane to an int-string (`str(int(lane))`) to avoid floating point artifacts like `"VW_2.0"`.

## Result

All tests passed – **10/10 points**.