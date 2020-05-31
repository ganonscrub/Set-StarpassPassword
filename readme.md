# Set-StarpassPassword

This PowerShell script allows you to update your Starpass account password if the Update Password page does not work.

As of writing, there appears to be a specific state in which your Starpass account may be that prevents the Update Password form from including all of the necessary fields. More specifically, it is possible for the web app to load without the current user's Username included in its scripts. Since the Username is a required field in the form but it does not exist, any attempt to update your password will fail.

It also seems that updating your password once fixes the bad state, and the web app will work properly (in my experience) after running this script.

## Notes
As I do not know how to get around reCAPTCHA from within a PowerShell script as the of the creation of this script, the **CaptchaResponse** parameter will need to be retrieved manually from the web app. To get this value:
1. Navigate to the Starpass login page (https://www.showcasecinemas.com/starpass/login)
2. Enable your browser's dev tools (usually by pressing the F12 key)
3. Go to your browser's dev tools Network tab and clear whatever requests are in there
4. Complete the reCAPTCHA
5. In your browser's dev tools Network tab, find and click the POST request made to https://www.google.com/recaptcha/api2/userverify
6. Inspect the request's response; it should be an array of 4 elements
7. Copy the array's second element, which should be a long string of nonsense characters
8. Paste the copied string of characters as the value of CaptchaResponse when invoking the script
9. To avoid PowerShell misinterpreting some characters that may appear in the CaptchaResponse value, wrap the string in single quotes
