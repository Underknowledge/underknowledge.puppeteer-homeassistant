const puppeteer = require('puppeteer');

const login_page = process.env.login_page || "https://homeassistant.underknowledge.cc/";
const login_username = process.env.login_username || "root";
const login_password = process.env.login_password || "un52SDvVfVOscyRVKi0D46p4NPbd8GXrDXFtHSd";


//login_page="https://homeassistant.underknowledge.cc/" login_username="root" login_password="un52SDvVfVOscyRVKi0D46p4NPbd8GXrDXFtHSd" ha_test.js

function sleep(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

(async () => {
  const browser = await puppeteer.launch({
  executablePath: '/usr/bin/google-chrome',
  headless: true,
  args: ['--no-sandbox', "--disabled-setupid-sandbox"], 
    // defaultViewport:{width:1366,height:768},
  ignoreHTTPSErrors: false,
  });
  const page = await browser.newPage();
  await page.goto(login_page, { waitUntil: 'networkidle0' });

  // find shadow elements by js selector
  // https://github.com/puppeteer/puppeteer/issues/858#issuecomment-438540596
// const username = await page.evaluateHandle(`document.querySelector("body > div > ha-authorize").shadowRoot.querySelector("ha-auth-flow").shadowRoot.querySelector("form > ha-form").shadowRoot.querySelector("div > ha-form-string:nth-child(1)").shadowRoot.querySelector("mwc-textfield").shadowRoot.querySelector("label > input")`);
  const username = await page.evaluateHandle(`document.querySelector("body > div > ha-authorize").shadowRoot.querySelector("ha-auth-flow").shadowRoot.querySelector("form > ha-form").shadowRoot.querySelector("div > ha-form-string:nth-child(1)").shadowRoot.querySelector("ha-textfield").shadowRoot.querySelector("label > input")`);
  await username.type(login_username);

  const password = await page.evaluateHandle(`document.querySelector("body > div > ha-authorize").shadowRoot.querySelector("ha-auth-flow").shadowRoot.querySelector("form > ha-form").shadowRoot.querySelector("div > ha-form-string:nth-child(2)").shadowRoot.querySelector("ha-textfield").shadowRoot.querySelector("label > input")`);
  await password.type(login_password);

  const loginHandle = await page.evaluateHandle(`document.querySelector("body > div > ha-authorize").shadowRoot.querySelector("ha-auth-flow").shadowRoot.querySelector("form > div > mwc-button")`);
  await loginHandle.click();

    // Set width.
    // 758x1024
  // await page.setViewport({ width: 1920, height: 600 });

  const desiredWidth = 758;
  const desiredHeight = 1024;
  const ScaleFactor = 1.35;

  await page.setViewport({ width: parseInt(desiredWidth / ScaleFactor), 
                           height: parseInt(desiredHeight / ScaleFactor), 
                           deviceScaleFactor: ScaleFactor });

  try {
    await sleep(1500); // lovelace has to load a lot of pictures

    const sidebarHandle = await page.evaluateHandle(`document.querySelector("body > home-assistant").shadowRoot.querySelector("home-assistant-main").shadowRoot.querySelector("#drawer > ha-sidebar").shadowRoot.querySelector("div.menu > ha-icon-button").shadowRoot.querySelector("mwc-icon-button").shadowRoot.querySelector("button")`);
    console.log("Never triggers because it fails");
    await sidebarHandle.click();
  } catch(e) {
      // console.log("caught: ", e);
  }

  await sleep(2500); // I guess the page resize does not render this fast
  // https://pptr.dev/#?product=Puppeteer&version=v13.0.1&show=api-pagescreenshotoptions
  // fullscreen 

  // Get the "viewport" of the page, as reported by the page.


  // https://github.com/puppeteer/puppeteer/issues/1273
  // screenshot = await page.screenshot({path: 'home_assistant.png', fullPage: true});


    // // Get scroll height of the rendered page and set viewport
    // const bodyHeight = await page.evaluate(() => document.body.scrollHeight);
    // await page.setViewport({ width: 758, height: bodyHeight });

    const dimensions = await page.evaluate(() => {
      return {
        width: document.documentElement.clientWidth,
        height: document.documentElement.clientHeight,
        deviceScaleFactor: window.devicePixelRatio,
      };
    });
  
    console.log('Dimensions:', dimensions);

    // Screenshot and exit.
    await page.screenshot({ 
      path: 'home_assistant.png', 
      fullPage: false 
      // fullPage: true 
    });

  // nice but no 
  // let [height, width] = await page.evaluate(() => {
  //   return [
  //     document.getElementsByTagName('html')[0].offsetHeight,
  //     document.getElementsByTagName('html')[0].offsetWidth
  //   ]
  // })
  
  // await page.screenshot({
  //   path: './home_assistant.png',
  //   clip: { x: 0, y: 0, width, height }
  // })

//   // partial, play around yourself
//   await page.screenshot({
//     path: 'home_assistant.jpg',
//     type: 'jpeg',
//     quality: 80,
//     clip: { x: 60, y: 145, width: 1010, height: 1150 }
//     });
  // // Close the browser
  await browser.close();
})();
