#!/usr/bin/env python3
import torch
import time
import argparse
from threading import Thread, Event

def keep_alive(stop_evt: Event,
               device: torch.device,
               mat_size: int = 512):
    """Continuously launch tiny matrix adds on the given GPU."""
    # allocate one small tensor once on this device
    x = torch.zeros((mat_size, mat_size), device=device)
    y = torch.ones_like(x, device=device)
    torch.cuda.synchronize(device)
    while not stop_evt.is_set():
        # a trivial GPU kernel launch
        z = x @ y
        # force completion on this device
        torch.cuda.synchronize(device)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--size", type=int, default=1024, help="Matrix size for the dummy operation")
    args = parser.parse_args()

    num_gpus = torch.cuda.device_count()
    if num_gpus == 0:
        raise RuntimeError("No CUDA devices available!")

    stop_evt = Event()
    threads = []
    for i in range(num_gpus):
        dev = torch.device(f"cuda:{i}")
        t = Thread(
            target=keep_alive,
            args=(stop_evt, dev, args.size),
            daemon=True,
        )
        t.start()
        threads.append(t)
        print(f"Started keep-alive on {dev}")

    try:
        # replace this with your real work
        while True:
            time.sleep(10)
    except KeyboardInterrupt:
        print("Shutting down keep-alives…")
    finally:
        stop_evt.set()
        for t in threads:
            t.join()
        print("All done.")