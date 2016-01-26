-- Preload the modules we're going to need
require("hs.chooser")
require("hs.webview")
require("hs.drawing")
require("hs.mjomatic")

-- Storage for persistent screen objects
local presentationControl = nil
local presentationScreen = nil
local slideBackground = nil
local slideHeader = nil
local slideBody = nil
local slideFooter = nil
local slideModal = nil

-- Configuration for persistent screen objects
local slideHeaderFont = nil
local slideHeaderSize = nil
local slideBodyFont = nil
local slideBodySize = nil
local slideFooterFont = nil
local slideFooterSize = nil

-- Metadata for slide progression
local startSlide = 1
local currentSlide = 0

-- Storage for transient screen objects
local refs = {}

-- List of safe default apps
local defaultapps = {"Calculator", "Chess", "Notes", "Dictionary"}

local mjomatic1={
    "   CCCChhhh",
    "   CCCChhhh",
    "NNNNNNDDDDD",
    "",
    "C Calculator",
    "h Chess",
    "N Notes",
    "D Dictionary"
}

local mjomatic2={
    "   hhhNNNNN",
    "   hhhNNNNN",
    "CCCCCDDDDDD",
    "",
    "C Calculator",
    "h Chess",
    "N Notes",
    "D Dictionary"
}

function launchdefaultapps()
    for k,v in pairs(defaultapps) do
        hs.application.launchOrFocus(v)
    end
end

function killdefaultapps()
    for k,v in pairs(defaultapps) do
        local app = hs.application.get(v)
        if app then
            app:kill()
        end
    end
end

function makewebview(name, place, url, html)
    if refs[name] then
        return refs[name]
    else
        print("Creating webview "..name)
        local frame = presentationScreen:fullFrame()
        local webViewRect
        if place == "right" then
            local x = frame["x"] + ((frame["w"] - 100)*0.66) + 10
            local y = slideHeader:frame()["y"] + slideHeader:frame()["h"] + 10
            local w = ((frame["w"] - 100)*0.33) - 10
            local h = slideBody:frame()["h"]
            webViewRect = hs.geometry.rect(x, y, w, h)
        elseif place == "body" then
            webViewRect = hs.geometry.rect(frame["x"] + 50,
                             slideHeader:frame()["y"] + slideHeader:frame()["h"] + 10,
                             (frame["w"] - 100),
                             (frame["h"] / 10) * 8 - (frame["h"] / 12))
        end
        local webview = hs.webview.new(webViewRect)
        webview:setLevel(hs.drawing.windowLevels["normal"]+1)
        if url then
            webview:url(url)
        elseif html then
            webview:html(html)
        else
            webview:html("NO CONTENT!")
        end
        refs[name] = webview
        return webview
    end
end

-- Definitions of the slides
local slides = {
    {
        ["header"] = "Hammerspoon",
        ["body"] = [[Staggeringly powerful desktop automation]],
        ["enterFn"] = function()
            killdefaultapps()
            local webview = makewebview("titleSlideWebview", "right", "http://www.hammerspoon.org/go/", nil)
            webview:show(0.3)
            print("Entered title slide")
        end,
        ["exitFn"] = function()
            print("Hiding webview")
            local webview = refs["titleSlideWebview"]
            webview:hide(0.2)
            print("Exited title slide")
        end,
    },
    {
        ["header"] = "Who am I?",
        ["body"] = [[Peter van Dijk, PowerDNS (lots of Lua in all our products!), contributor to Hammerspoon predecessors, mostly passively involved in Hammerspoon development.]]
    },
    {
        ["header"] = "What is it?",
        ["body"] = [[Hammerspoon exposes many OS X system APIs to a Lua environment, so you can script your environment.]]
    },
    {
        ["header"] = "History",
        ["body"] = [[Hammerspoon is a fork of Mjolnir by Steven Degutis. Mjolnir aims to be a very minimal application, with its extensions hosted externally and managed using a Lua package manager. We wanted to provide a more integrated experience.]]
    },
    {
        ["header"] = "A comparison",
        ["enterFn"] = function()
            local webview = makewebview("comparisonSlideWebview", "body", "https://github.com/sdegutis/mjolnir#mjolnir-vs-other-apps", nil)
            webview:show(0.3)
        end,
        ["exitFn"] = function()
            local webview = refs["comparisonSlideWebview"]
            webview:hide(0.2)
        end,
    },
    {
        ["header"] = "So what is it for",
        ["body"] = [[• Window management
• Reacting to all kinds of events
  • WiFi, USB, path/file changes
• Interacting with applications (menus)
• Drawing custom interfaces on the screen
• URL handling/mangling]]
    },
    {
        ["header"] = "Window management (1)",
        ["body"] = "Just launching some apps",
        ["enterFn"] = function()
            launchdefaultapps()
        end
    },
    {
        ["header"] = "Window management (2)",
        ["body"] = "Mjomatic config:\n"..table.concat(mjomatic1, "\n"),
        ["enterFn"] = function ()
            for k,v in pairs(defaultapps) do
                local app = hs.application.get(v)
                if app then
                    local window = app:mainWindow()
                    if window then
                        window:moveToScreen(presentationScreen)
                    end
                end
            end
            -- local webview = makewebview("mjomaticSlideWebview", "body", nil, "<pre>Mjomatic config:\n"..table.concat(mjomatic1, "\n").."</pre>")
            -- webview:show(0.3)

        end,
        -- ["exitFn"] = function()
        --     local webview = refs["mjomaticSlideWebview"]
        --     webview:hide(0.2)
        -- end
    },
    {
        ["header"] = "Window management (3)",
        ["body"] = "Mjomatic config:\n"..table.concat(mjomatic2, "\n"),
        ["exitFn"] = function()
            killdefaultapps()
        end
    },
    {
        ["header"] = "Responding to WiFi events",
        ["enterFn"] = function()
          local webview = makewebview("wifiwatcherSlideWebview", "body", nil, [[<pre>
wifiwatcher = hs.wifi.watcher.new(function()
  print"wifiwatcher fired"
  local network = hs.wifi.currentNetwork()
  if network then
    hs.alert("joined wifi network "..network)
  else
    hs.alert("wifi disconnected")
  end
  if network == "Fibonacci" then
    hs.application.launchOrFocus("Twitter")
  else
    local app = hs.application.get("Twitter")
    if app then
      app:kill9()
    end
  end
end)
wifiwatcher:start()
</pre>]])
          webview:show(0.3)
        end,
        ["exitFn"] = function()
          local webview = refs["wifiwatcherSlideWebview"]
          webview:hide(0.2)
        end
    },
    {
        ["header"] = "Handling URL events",
        ["enterFn"] = function()
            local webview = makewebview("URLSlideWebview", "body", "", '<img src="https://cloud.githubusercontent.com/assets/353427/9669248/c37c6f26-527d-11e5-9299-41b3cdcb4a04.png">')
            webview:show(0.3)
        end,
        ["exitFn"] = function()
            local webview = refs["URLSlideWebview"]
            webview:hide(0.2)
        end
    },
    {
        ["header"] = "Command line interface",
        ["body"] = "insert screenshot of simple hs cli example"
    },
    {
        ["header"] = "Other modules",
        ["body"] = [[alert appfinder applescript application audiodevice battery brightness caffeinate chooser drawing eventtap expose geometry grid hints host hotkey http httpserver image itunes javascript layout location menubar messages milight mouse notify pasteboard pathwatcher redshift screen sound spaces speech spotify tabs task timer uielement urlevent usb webview wifi]]
    },
    {
        ["header"] = "LuaSkin",
        ["enterFn"] = function()
            local webview = makewebview("LuaSkinSlideWebview", "body", "https://github.com/Hammerspoon/hammerspoon/issues/749#issuecomment-173610148", nil)
            webview:show(0.3)
        end,
        ["exitFn"] = function()
            local webview = refs["LuaSkinSlideWebview"]
            webview:hide(0.2)
        end
    },
    {
        ["header"] = "Questions?"
    }
}

-- Draw a slide on the screen, creating persistent screen objects if necessary
function renderSlide(slideNum)
    print("renderSlide")
    if not slideNum then
        slideNum = currentSlide
    end
    print("  slide number: "..slideNum)

    local slideData = slides[slideNum]
    local frame = presentationScreen:fullFrame()

    if not slideBackground then
        slideBackground = hs.drawing.rectangle(frame)
        slideBackground:setLevel(hs.drawing.windowLevels["normal"])
        slideBackground:setFillColor(hs.drawing.color.hammerspoon["osx_yellow"])
        slideBackground:setFill(true)
        slideBackground:show(0.2)
    end

    if not slideHeader then
        slideHeader = hs.drawing.text(hs.geometry.rect(frame["x"] + 50,
                                                       frame["y"] + 50,
                                                       frame["w"] - 100,
                                                       frame["h"] / 10),
                                                       "")
        slideHeader:setTextColor(hs.drawing.color.x11["black"])
        slideHeader:setTextSize(slideHeaderSize)
        slideHeader:orderAbove(slideBackground)
    end

    slideHeader:setText(slideData["header"])
    slideHeader:show(0.5)

    if not slideBody then
        slideBody = hs.drawing.text(hs.geometry.rect(frame["x"] + 50,
                                                     slideHeader:frame()["y"] + slideHeader:frame()["h"] + 10,
                                                     (frame["w"] - 100)*0.66,
                                                     (frame["h"] / 10) * 8),
                                                     "")
        slideBody:setTextColor(hs.drawing.color.x11["black"])
        slideBody:setTextSize(slideBodySize)
        slideBody:orderAbove(slideBackground)
    end

    slideBody:setText(slideData["body"] or "")
    slideBody:show(0.5)

    if not slideFooter then
        slideFooter = hs.drawing.text(hs.geometry.rect(frame["x"] + 50,
                                                       frame["y"] + frame["h"] - 50 - slideFooterSize,
                                                       frame["w"] - 100,
                                                       frame["h"] / 25),
                                                       "Hammerspoon: Staggeringly powerful desktop automation")
        slideFooter:setTextColor(hs.drawing.color.x11["black"])
        slideFooter:setTextSize(slideFooterSize)
        slideFooter:orderAbove(slideBackground)
        slideFooter:show(0.5)
    end
end

-- Move one slide forward
function nextSlide()
    if currentSlide < #slides then
        if slides[currentSlide] and slides[currentSlide]["exitFn"] then
            print("running exitFn for slide")
            slides[currentSlide]["exitFn"]()
        end

        currentSlide = currentSlide + 1
        renderSlide()

        if slides[currentSlide] and slides[currentSlide]["enterFn"] then
            print("running enterFn for slide")
            slides[currentSlide]["enterFn"]()
        end
    end
end

-- Move one slide back
function previousSlide()
    if currentSlide > 1 then
        if slides[currentSlide] and slides[currentSlide]["exitFn"] then
            print("running exitFn for slide")
            slides[currentSlide]["exitFn"]()
        end

        currentSlide = currentSlide - 1
        renderSlide()

        if slides[currentSlide] and slides[currentSlide]["enterFn"] then
            print("running enterFn for slide")
            slides[currentSlide]["enterFn"]()
        end
    end
end

-- Exit the presentation
function endPresentation()
    hs.caffeinate.set("displayIdle", false, true)
    if slides[currentSlide] and slides[currentSlide]["exitFn"] then
        print("running exitFn for slide")
        slides[currentSlide]["exitFn"]()
    end
    slideHeader:hide(0.5)
    slideBody:hide(0.5)
    slideFooter:hide(0.5)
    slideBackground:hide(1)

    hs.timer.doAfter(1, function()
        slideHeader:delete()
        slideBody:delete()
        slideFooter:delete()
        slideBackground:delete()
        slideModal:exit()
    end)
end

-- Prepare the modal hotkeys for the presentation
function setupModal()
    print("setupModal")
    slideModal = hs.hotkey.modal.new({}, nil, nil)

    slideModal:bind({}, "left", previousSlide)
    slideModal:bind({}, "right", nextSlide)
    slideModal:bind({}, "escape", endPresentation)

    slideModal:bind({}, "M", function()
            for k,v in pairs(defaultapps) do
                local app = hs.application.get(v)
                if app then
                    local window = app:mainWindow()
                    if window then
                        window:raise()
                    end
                end
            end
            hs.mjomatic.go(mjomatic1)
        end)
    slideModal:bind({}, "N", function()
            for k,v in pairs(defaultapps) do
                local app = hs.application.get(v)
                if app then
                    local window = app:mainWindow()
                    if window then
                        window:raise()
                    end
                end
            end
            hs.mjomatic.go(mjomatic2)
        end)

    slideModal:enter()
end

-- Callback for when we've chosen a screen to present on
function didChooseScreen(choice)
    if not choice then
        print("Chooser cancelled")
        return
    end
    print("didChooseScreen: "..choice["text"])
    presentationScreen = hs.screen.find(choice["uuid"])
    if not presentationScreen then
        hs.notify.show("Unable to find that screen, using primary screen")
        presentationScreen = hs.screen.primaryScreen()
    else
        print("Found screen")
    end

    setupModal()

    local frame = presentationScreen:fullFrame()
    slideHeaderSize = frame["h"] / 15
    slideBodySize   = frame["h"] / 22
    slideFooterSize = frame["h"] / 30

    nextSlide()
end

-- Prepare a table of screens for hs.chooser
function screensToChoices()
    print("screensToChoices")
    local choices = hs.fnutils.map(hs.screen.allScreens(), function(screen)
        local name = screen:name()
        local id = screen:id()
        local image = screen:snapshot()
        local mode = screen:currentMode()["desc"]

        return {
            ["text"] = name,
            ["subText"] = mode,
            ["uuid"] = id,
            ["image"] = image,
        }
    end)

    return choices
end

-- Initiate the hs.chosoer for choosing a screen to present on
function chooseScreen()
    print("chooseScreen")
    local chooser = hs.chooser.new(didChooseScreen)
    chooser:choices(screensToChoices)
    chooser:show()
end

-- Prepare the presentation
function setupPresentation()
    print("setupPresentation")
    hs.caffeinate.set("displayIdle", true, true)
    chooseScreen()
end

-- Create a menubar object to initiate the presentation
presentationControl = hs.menubar.new()
--presentationControl:setIcon(hs.image.imageFromName(hs.image.systemImageNames["EnterFullScreenTemplate"]))
presentationControl:setIcon(hs.image.imageFromName("NSComputer"))
presentationControl:setMenu({{ title = "Start Presentation", fn = setupPresentation }})

