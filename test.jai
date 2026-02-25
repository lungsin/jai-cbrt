#import,file "module.jai";
#import "Basic";
#import "Math";
#import "Random";

cube :: (n: float64) -> float64 {return n * n * n;}

Error_Stats :: struct {
    max_abs_err, avg_abs_err: float64; // Absolute error stats
    max_rel_err, avg_rel_err: float64; // Relative error stats
    n_count: u64;
}

format_err :: inline (v: Any) -> FormatFloat {
    return FormatFloat.{value = v, mode = FormatFloat.Mode.SCIENTIFIC};
}

add_err :: inline (stats: *Error_Stats, abs_err: float64, rel_err: float64) {
    stats.n_count += 1;
    stats.max_abs_err = max(stats.max_abs_err, abs_err);
    stats.avg_abs_err += abs_err;
    stats.max_rel_err = max(stats.max_rel_err, rel_err);
    stats.avg_rel_err += rel_err;
}

compute_avg :: (err: *Error_Stats) {
    err.avg_abs_err /= err.n_count;
    err.avg_rel_err /= err.n_count;
}

print_err_stats :: (err: Error_Stats) {
    print("Count: %\n", err.n_count);
    print("[Absolute error] Max: %, Avg: %\n", format_err(err.max_abs_err), format_err(err.avg_abs_err));
    print("[Relative error] Max: %, Avg: %\n", format_err(err.max_rel_err), format_err(err.avg_rel_err));
    print("\n");
}

test_accuracy_cbrt_cube :: (gen_n_fn: () -> float64, cbrt_fn: (float64) -> float64, desc: string) {
    err: Error_Stats;
    N_COUNT :: 100_000;
    for 1..N_COUNT {
        n := gen_n_fn();

        n_cbrt_approx := cbrt_fn(n);
        n_approx := cube(n_cbrt_approx);

        abs_err := abs(n_approx - n);
        rel_err := abs_err / abs(n);
        add_err(*err, abs_err, rel_err);
    }
    compute_avg(*err);
    print("Test accuracy cbrt -> cube -> compare\n");
    print("Desc: %\n", desc);
    print_err_stats(err);
}

test_accuracy_cube_cbrt :: (gen_n_fn: () -> float64, cbrt_fn: (float64) -> float64, desc: string) {
    err: Error_Stats;
    N_COUNT :: 100_000;
    for 1..N_COUNT {
        n := gen_n_fn();
        n_cube := cube(n);
        n_approx := cbrt_fn(n_cube);

        abs_err := abs(n_approx - n);
        rel_err := abs_err / abs(n);
        add_err(*err, abs_err, rel_err);
    }
    compute_avg(*err);
    print("Test accuracy cube -> cbrt -> compare\n");
    print("Desc: %\n", desc);
    print_err_stats(err);
}

cbrt_pow :: (x: float64) -> float64 {
    sign := false;
    if (x < 0) {
        sign = true;
        x = -x;
    }

    result := pow(x, 1.0 / 3.0);
    if sign result = -result;
    return result;
}

main :: () {
    test_accuracy_cbrt_cube(() -> float64 {return random_get_zero_to_one_new() * 10;}, cbrt, "Using cbrt function");
    test_accuracy_cbrt_cube(() -> float64 {return random_get_zero_to_one_new() * 10;}, cbrt_pow, "Using pow function");

    test_accuracy_cube_cbrt(() -> float64 {return random_get_zero_to_one_new() * 10;}, cbrt, "Using cbrt function");
    test_accuracy_cube_cbrt(() -> float64 {return random_get_zero_to_one_new() * 10;}, cbrt_pow, "Using pow function");
}
