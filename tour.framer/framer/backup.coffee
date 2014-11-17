# This imports all the layers for "tour" into ly
ly = Framer.Importer.load "imported/tour"

## ---------------- VARIABLES -----------------
# create variables for ease of use and modularity of your code
welcome = ly.welcome
dots = ly.dots
moveDot = ly.movingDot
done = ly.doneButton
login = ly.login
logo = ly.logo
news = ly.newsFeed
sidebar = ly.sidebar
gradient = ly.gradient
gradient2 = ly.gradient2
background = ly.background
feedDescription = ly.feedDescription
sidebarDescription = ly.sidebarDescription
all = ly.all
celebs = ly.celebs
newsLayers = [ly.celeb1, ly.celeb2, ly.celeb3, ly.celeb4, ly.celeb5, ly.celeb6]
for user in newsLayers
	user.x = 750

## ------------ CONFIGURATION -------------
sidebar.x = -660
gradient.sendToBack()
gradient.style = scale: 0

# define your draggable layers in an array
dragLayers = [welcome, gradient, gradient2]
# create a for loop to enable dragging on draggable layers
for drag in dragLayers
	# Enable dragging
	drag.draggable.enabled = true
	drag.draggable.speedY = 0
	# Prevent dragging left to right
	drag.draggable.maxDragFrame = drag.frame
	drag.draggable.maxDragFrame.width *= 2
	drag.draggable.maxDragFrame.x = drag.x-drag.width


## ------------ STATES -------------
# create states for all of your different interactive components
welcome.states.add
	shown: { x: welcome.originX }
	hidden: { x: -750 }

news.states.add
	origin: { x: 750 }
	shown: { x: news.originX }
	sidebar: { x: 655 }
	hidden: { x: -750 }

celebs.states.add
	origin: { x: 750 }
	shown: { x: news.originX }
	sidebar: { x: 655 }
	hidden: { x: -750 }

gradient.states.add
	origin: {x: 750}
	shown: {x: 0 }
	hidden: {x: -750 }
	
gradient2.states.add
	origin: {x: 750}
	shown: {x: 0 }
	hidden: {x: -750 }

sidebar.states.add 
	hidden: { x: -750 }
	shown: { x: 0 }

moveDot.states.add
	first: { x: moveDot.x }
	second: { x: (dots.x + 30) }
	third: { x: (dots.x + 73) }
	fourth: { x: (dots.x + 115) }


## ------------ ANIMATION PRESETS -------------
# create presets to easily re-use common elements and interactions
bouncyCurve = 'spring(150, 30, 30)'  
newsCurve = 'spring(50, 30, 30)'

# set some reusable values. You can later call layer.fadeIn(), layer.initialGrow() for example
Layer::fadeIn = ->
	this.animate
		properties: 
			opacity: 1
		curve: 'ease-in-out'
		time: 0.25

Layer::fadeOut = ->
	this.animate
		properties: 
			opacity: 0
		curve: 'ease-in-out'
		time: 0.1
        
Layer::initialGrow = ->
	this.animate
		properties:
  			scale: 0
		time: 0.1
   
Layer::bounceGrow = ->
	this.animate
		properties:
			scale: 1
		curve: bouncyCurve
		time: .2

# you can target animation options for the states in a layer
news.states.animationOptions =
	delay: 0.06
	curve: 'spring'
	curveOptions: { tension: 200, friction: 50, velocity: 20 }
	
moveDot.states.animationOptions =
	time: 0.05
	curve: 'spring'
	curveOptions: { tension: 400, friction: 70, velocity: 20 }

welcomeOriginAnimation = 
	curve: 'spring'
	curveOptions: { tension: 500, friction: 50, velocity: 0 }
	time: 0.2

# create functions for interactions that will need to be re-used. This function is used when the done button is clicked, and when the user reaches the last step of the product tour, for example	. Call it via loginState()
loginState = ->
	done.fadeOut()
	all.fadeOut()	
	news.fadeOut()
	dots.fadeOut()
	moveDot.fadeOut()
	Utils.delay .22, ->
		welcome.fadeOut()
	Utils.delay .82, ->
		login.bounceGrow()
		login.bringToFront()


## ------------ SET INITIAL STATE OF SOME ELEMENTS -------------
# set the initial size of the elements that will grow later
gradient.initialGrow()
feedDescription.initialGrow()
gradient2.initialGrow()
sidebarDescription.initialGrow()

gradient.x = 750
ly.statusBar.bringToFront()
login.initialGrow()

# animate each celebrity status update initially
newsAnimation = ->
	for i in [0 .. newsLayers.length-1]
		newsLayers[i].animate
			delay: i * 0.1
			properties:
				x: 0
			curve: newsCurve

# animate celebrity status updates out to left
newsAnimationOut = ->
	for i in [0 .. newsLayers.length-1]
		newsLayers[i].animate
			delay: i * 0.1
			properties:
				x: (background.originX - 1450)
			curve: bouncyCurve


## ------------ EVENTS -------------
# when dragging begins, place the news feed to the right of the screen
welcome.on Events.DragStart, ->
	news.x = 750
	celebs.bringToFront()

# initial welcome state	
welcome.on Events.DragEnd, ->
	# if the user drags right to left more than 150 pixels, switch the states of the elements
	if welcome.screenFrame.x < -150
		welcome.states.switch "hidden"
		news.states.switch "shown"
		newsAnimation()
		celebs.sendToBack()
		moveDot.states.switch "second"
		gradient.states.switch "shown"
		# animate the logo to disappear
		logo.animate
			properties:
				scale: 0
			time: .05

		# delay the appearance of the gradient overlay until the news feed  is visible
		Utils.delay 1.2, ->
			gradient.bounceGrow()
			feedDescription.bounceGrow()			
	else
		# if the user has not dragged far enough to the left, reset to the initial state (ie. they accidentally dragged, not far enough to signal a swipe)
		welcome.states.switch("shown", welcomeOriginAnimation)
		news.states.switch("origin", welcomeOriginAnimation)
		moveDot.states.switch("first", welcomeOriginAnimation)

# show news feed state
gradient.on Events.DragEnd, ->
	if (gradient.screenFrame.x) < -150
		news.states.switch "sidebar"
		moveDot.states.switch "third"
		sidebar.states.switch("shown", welcomeOriginAnimation)
		gradient.states.switch "hidden"
		celebs.states.switch("sidebar", welcomeOriginAnimation)
		ly.feedDescription.sendToBack()
		Utils.delay 1.1, ->
			gradient2.bounceGrow()
			sidebarDescription.bounceGrow()
	else
		news.states.switch("shown", welcomeOriginAnimation)
		gradient.states.switch("shown", welcomeOriginAnimation)
		celebs.states.switch("shown", welcomeOriginAnimation)
		
# show sidebar state	
gradient2.on Events.DragEnd, ->
	if (gradient2.screenFrame.x) < -150
		news.states.switch("hidden", welcomeOriginAnimation)
		sidebar.states.switch("hidden", welcomeOriginAnimation)
		moveDot.states.switch "fourth"
		gradient2.states.switch("hidden", welcomeOriginAnimation)
		newsAnimationOut()
		Utils.delay .6, ->
			loginState()
	else
		news.states.switch("sidebar", welcomeOriginAnimation)
		gradient2.states.switch("shown", welcomeOriginAnimation)
		sidebar.states.switch("shown", welcomeOriginAnimation)
		moveDot.states.switch("third", welcomeOriginAnimation)
		
# if user clicks done before tour is finished, show them the login screen
done.on Events.Click, ->
	logo.animate
		properties:
			scale: 0
		time: .15
	Utils.delay .2, ->
		loginState()
