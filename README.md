# Swift static linking bug demo project

When these three conditions are true:
1. build a simple Vapor app using `-Xswiftc -static-executable`, and
2. that app includes http calls using `async-http-client`, and
3. there is at least 60 seconds between a previous call and a subsequent call

Then Vapor will segfault.

It only happens when the app was compiled statically.

## Demo script

Run the `make_bug_go_boom.sh` script to demonstrate the crash.
