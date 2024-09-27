import asyncio
import time
import sys
import os

from gufo.ping import Ping

host = "142.250.189.206"
hosts = [host] * int(sys.argv[1])

INTERVAL = 5

def count_open_file_handles():
    return 1
    #return len(os.listdir('/proc/self/fd'))

async def ping_host(ping, host):
    try:
        r = await ping.ping(host)
        if r:
            return True
        else:
            return False
    except TimeoutError as err:
        print(f'timeout to ping {host}. Error: {err}')
        return False
    except Exception as err:
        print(f'failed to ping {host} Error: {err}')
        return False

async def ping_all_hosts(ping):
    tasks = [ping_host(ping,host) for host in hosts]
    results = await asyncio.gather(*tasks)

    success_count = sum(results)
    failure_count = len(results) - success_count

    return success_count, failure_count

async def main():
    ping = Ping(timeout=1,recv_buffer_size=16777216)
    while True:
        start_time = time.time()
        success, failure = await ping_all_hosts(ping)
        handles = count_open_file_handles()
        print(f"Round complete: {success} successes, {failure} failures, fds {handles} host {host}")
        elapsed_time = time.time() - start_time
        sleep_time = max(0, INTERVAL - elapsed_time)
        await asyncio.sleep(sleep_time)

if __name__ == '__main__':
    asyncio.run(main())

