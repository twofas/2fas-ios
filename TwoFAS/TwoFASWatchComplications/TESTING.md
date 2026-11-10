# Launch complication checks

Build and install the `TwoFASWatch Watch App` scheme on a paired Watch simulator
or a development Watch. Prepare the open-source files described in
`CONTRIBUTING.md` when building without the encrypted resources.

1. Edit a watch face and select 2FAS in each supported slot: circular, corner,
   inline, and rectangular. Use multiple faces as needed.
2. Check that the key icon is legible and that inline and rectangular slots
   display the 2FAS label. Check tinted and full-color faces where available.
3. Tap the complication with the app closed, then with the app already running.
   Both should open the Watch app at its normal entry point.
4. Enable the Watch app PIN using disposable test data, lock the app, and tap
   the complication. Confirm the existing PIN screen still protects the app.
5. Check VoiceOver announces “Open 2FAS”.

The launcher has static content and no scheduled refreshes. It does not access
authentication secrets or display TOTP codes.
