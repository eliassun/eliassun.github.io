# Author: Elias Sun

import asyncio

host = "142.250.189.206"

async def ping_task(cpe, ret):
    result = False
    host = cpe.get("ping_dns_ip")
    try:
        process = await asyncio.create_subprocess_exec(
            'ping', '-c', '1', '-W', '1', host,  # '-c 1' means send 1 packet
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.PIPE
        )
        stdout, stderr = await process.communicate()
        if process.returncode == 0:
            result = True
        else:
            pass
    except Exception as e:
        pass
    if not result:
        ret["failed"] = ret["failed"] + 1
    else:
        ret["pass"] = ret["pass"] + 1

def load_ping_tasks(tasks, result):
    cpes = []

    for i in range(1000):
        cpes.append({
            "ping_dns_ip": host 
        })
    for cpe in cpes:
        tasks.append(ping_task(cpe, result))

async def run_tasks(result):
    tasks = []
    load_ping_tasks(tasks, result)
    await asyncio.gather(*tasks)

async def main():
    count = 0
    while True:
        count = count + 1
        result = {
            "round": count,
            "pass": 0,
            "failed": 0,
            "host": host,
        }
        await run_tasks(result)
        print(result)
        await asyncio.sleep(5)

if __name__ == "__main__":
    asyncio.run(main())
  
