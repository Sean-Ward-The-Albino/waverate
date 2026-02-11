import subprocess

try:
    result = subprocess.run(['git', 'status'], capture_output=True, text=True, timeout=10)
    with open('git_status.txt', 'w') as f:
        f.write(result.stdout)
        f.write('\nError:\n')
        f.write(result.stderr)
except Exception as e:
    with open('git_status.txt', 'w') as f:
        f.write(str(e))
