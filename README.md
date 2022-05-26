Homeassistant Kindle Pupeteer
--- 
Containerized Pupeteer setup to bring an image of a Home Assistant dashboard to Kindle!   

    Puppeteer is a Node library which provides a high-level API to control headless Chrome or Chromium over the DevTools Protocol.
    It can also be configured to use full (non-headless) Chrome or Chromium. 


A pretty specific container tailored to my use case.   
I received a rooted Kindle PW1 with SSH access as a gift. I still use it (occasionally) for reading, but most of the time it gathers dust in a corner until I need it and it ran out of power last week..
Let's use it instead as a dasboard for the weather!

![](home_assistant.png =379x512)


When you want to follow on,    
Search on the web for something like `Kindle ssh access` and I bet you'll find a lot of resources to set up your Reader that way.  the [Mobileread Forum](https://www.mobileread.com) is cind of the main hub for kindle personilasation. 


# Setup 

```bash
git clone https://github.com/Underknowledge/underknowledge.puppeteer-homeassistant /opt/puppeteer-homeassistant
cd /opt/puppeteer-homeassistant
```

Move the `.env_sample` to `.env` and change the values according to your needs 


    KINDLE_IP=10.0.0.12
    KINDLE_PASSWORD=kindle
    HOMEASSISTANT_LOGIN_USER=kindle
    HOMEASSISTANT_LOGIN_PASS=kindle
    HOMEASSISTANT_URL="http://10.0.0.27:8123/vr-welcome/kindle?kiosk"
    # Time between screen updates
    SLEEP=1m
    # Time to wait when the reader is in use. More to it below
    READING_DURATION=2h

afterwards it is just 
```bash
docker-compose up -d 
```
This will pull the latest `node` container and install some tools to run this

It's fun to refresh the screen every minute, but that would prevent the main functionality.
If you want to use your reader, set the brightness to maximum until the next picture update occurs. 
If the Reader brightness is above `240`, the script will sleep as long as you set your `$READING_DURATION`. 
you can use the options of sleep (`60, 60s, 1m, 2h, ...`)
 
# Tweaking 

in `home_assistant.js` you might should able to dial around with these settings.  

    const desiredWidth = 758;
    const desiredHeight = 1024;
    const ScaleFactor = 1.35;



And always remember, 
If you do not have root privileges, it is not your device.