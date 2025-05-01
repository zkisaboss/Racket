#!/usr/bin/python3
# #######################
#
# This file runs tests for this coding assignment.
# Read the file but do not modify.
#
# #######################

import os, sys, subprocess, json, argparse, signal
from subprocess import Popen, PIPE, STDOUT, TimeoutExpired


#####################
# Start Test Utilities
#####################

def preparefile(file):
    pass

def runcmdsafe(binfile):
    b_stdout, b_stderr, b_exitcode = runcmd(binfile)
    return b_stdout, b_stderr, b_exitcode

def runcmd(cmd):
    stdout, stderr, process = None, None, None
    if os.name != 'nt':
        cmd = "exec " + cmd
    with Popen(cmd, shell=True, stdin=PIPE, stdout=PIPE, stderr=STDOUT) as process:
        try:
            stdout, stderr = process.communicate(timeout=30)
        except TimeoutExpired:
            if os.name == 'nt':
                Popen(f"TASKKILL /F /PID {process.pid} /T")
            else:
                process.kill()
                exit()
    return stdout, stderr, process.returncode

def assertequals(expected, actual):
    if expected == actual:
        passtest('')
    else:
        failtest(f'Expected {expected} got {actual}')

def failtest(message):
    testmsg('failed', message)

def passtest(message):
    testmsg('passed', message)

def testmsg(status, message):
    x = {
      "status": status,
      "message": message
    }
    print(json.dumps(x))
    sys.exit()

#####################
# End Test Utilities
#####################

verbose = False

def runtest(name):
    global verbose
    print('---------------------')
    print(f'\nRunning test: {name}')
    python_bin = sys.executable
    test_dir = os.path.join("test", name)

    try:
        output = subprocess.check_output(
            f'"{python_bin}" driver.py',
            cwd=test_dir,
            shell=True,
            stderr=subprocess.STDOUT
        )
        y = json.loads(output)
    except subprocess.CalledProcessError as e:
        print("     FAILED (script error)")
        print(e.output.decode())
        return False
    except json.JSONDecodeError:
        print("     FAILED (invalid JSON output)")
        print(output.decode())
        return False

    status = y.get("status", "failed")
    message = y.get("message", "")
    if verbose and message:
        print("\n\nSTDOUT:")
        print(message)
    if status == "passed":
        print("     PASSED")
        return True
    else:
        print("     FAILED")
        return False

def runtests():
    tests = listtests()
    num_passed = 0
    for test in tests:
        if runtest(test):
            num_passed += 1

    print('\n===========================')
    print(f'Summary: {num_passed} / {len(tests)} tests passed')
    print('===========================')

def listtests():
    test_dir = "test"
    return sorted([
        name for name in os.listdir(test_dir)
        if os.path.isdir(os.path.join(test_dir, name))
    ])

def main():
    global verbose

    parser = argparse.ArgumentParser()
    parser.add_argument('--list', '-l', help='List available tests', action='store_true')
    parser.add_argument("--all", "-a", help='Perform all tests', action='store_true')
    parser.add_argument('--verbose', '-v', help='View test stdout, verbose output', action='store_true')
    parser.add_argument('--test', '-t', help='Perform a specific testname (case sensitive)')
    args = parser.parse_args()

    if args.verbose:
        verbose = True

    if args.all:
        runtests()
        return

    if args.test:
        if not os.path.isdir(f'test/{args.test}'):
            print(f"Test \"{args.test}\" not found or not a directory")
            return
        runtest(args.test)
        return

    if args.list:
        print("Available tests:")
        print(*listtests(), sep='\n')
        return

    parser.print_help()

if __name__ == "__main__":
    main()
