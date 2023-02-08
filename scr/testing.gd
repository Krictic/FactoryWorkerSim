extends Panel
# Misc. Variables that could serve multiple functions
var buttonCount = 0
var totalCash = 0
#var format_cash = "Cash:\n" + str(pounds) + " pounds\n" + str(shillings) + " shillings\n" + str(pennies) + " pennies "
var time_start = 0
var time_now = 0
var overtime_toggled = false
var game_over = false

# Log Variables
var logList = []
var climateLog = []

# Health variables
var health = clamp(100, 0, 100)
var health_status = ""

#var lifeExpectancy_var = round(lifeExpectancy_func() * 365.3)
var lifeExpectancy_var = round(lifeExpectancy_func() * 365.3)
var lifeExpectancyYears_var = lifeExpectancy_func()

# Job-related variables
var currentJob = "Asembly Line Worker"
var firingChance = 1

# Coins of 19th England
# Will not be used until i figure out how to properly convert the values
#var pennies = 0.00
#var shillings = 0.00
#var pounds = 0.00

# For calculating salary
# Formula is: salaryHour * workHours
# There is a chance those variables might increase or decrease
# But for now those are fixed at 2,492 pennies per day
var salaryHour = 0.178
var workhours = 14
var workdays = 6
var wage = 0
var oldWage = 0

# Date variables to be formated like "5:00 (AM), Monday, January 10th, 1870"
var hour = 5
var minutes = 0
var amPM = "AM"
var weekDay = 1
var monthDay = 1
var monthWeek = 1
var currentMonth = "January"
var currentYear = 1870
var totalDays = 1

# Thiss should check if any given year is a bisect year
# Because I wish to keep accurate track fo time.
var isLeapYear = isBisectyear()
var leapYearList = leap_year_list_maker(lifeExpectancyYears_var)

# Laws Variables
var overtimeLaw = true

# Climate variables
var outTemp = temperature()
var weather = weather(outTemp)
var weatherStatus = ""
var seasonStatus = "Winter"

func _ready():
	if overtimeLaw == false:
		$innerPanel/CheckButton.disabled = true
	time_start = float(OS.get_ticks_msec()) / 1000
	pass

# Keep the money label updated.
func _process(_delta):
	
	if not game_over:
	
		# Check health
		status()
		
		# Check wages
		if currentJob != "Unemployed":
			if overtime_toggled == false:
				wage = wageFunc()
			else:
				overtime_wage()
		else:
			unemployment()
		# Check Cost of Living Loss every 7 days
		if buttonCount == 7:
			livingCostLoss()
		
		# Check life expectancy left and give game over if it is 0
		if lifeExpectancy_var == 0:
			gameOver()
			game_over = true
			
		
		$innerPanel/moneyLabel.text = "Cash:\n" + str(totalCash) + " pennies"
		$innerPanel/healthLabel.text = "Current health is " + str(health_status) +" ( " + str(health) + " )"
		$innerPanel/jobLabel.text = "Job: " + str(currentJob)
		$innerPanel/daysLabel.text = "Day " + str(totalDays)
		$innerPanel/dateLabel.text = str(currentMonth) + ", " + str(monthDay) + " " + str(currentYear)
		$innerPanel/lifeLabel.text = "Your life expectancy is: " + str(lifeExpectancy_var) + " days (" + str(lifeExpectancyYears_var) + " years" + ")"
		$innerPanel/climateLabel.text = "Today´s weather is: " + str(weather) + " " + str(outTemp) + "°C"
		$innerPanel/seasonLabel.text = "Current season: " + str(seasonStatus)
		
# Health status button
# Mostly comestic for now
func status():
	if health >=90:
		health_status = "Perfect"
	elif health >= 75:
		health_status = "Tired"
	elif health >= 50:
		health_status = "Unwell"
	elif health >= 40:
		health_status = "Light Sickness"
	elif health >= 30:
		health_status = "Mild Sickness"
	elif health >= 15:
		health_status = "Severe Illness"
	elif health >= 1:
		health_status = "Near Death"
	else:
		health_status = "Game Over, press restart."

func wageFunc():
	return workhours * salaryHour
	
func overtime_wage():
	var overhours = workhours + 2
	return overhours * salaryHour
	
func cost_living():
	if currentJob != "Unemployed":
		var wageValue = wage * 7
		var wageStart = wageValue * 0.75
		var wageEnd = wageValue * 0.9
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var randomCost = rng.randf_range(wageStart, wageEnd)
		return randomCost
	else:
		var baseCost = 5 # Tis is to represent lowered living standards
		var costStart = baseCost * 0.9
		var costEnd = baseCost * 1.5 # 50% variation
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var randomCost = rng.randf_range(costStart, costEnd)
		return randomCost

func livingCostLoss():
	var cost = cost_living()
	totalCash -= cost
	buttonCount = 0
	#time_now = OS.get_ticks_msec() / 1000
	#var time_elapsed = time_now - time_start
	$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "You have lost: " + str(cost))
	logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "You have lost: " + str(cost)))
	
# Not currently working
# Come back to this
func leap_year_list_maker(years):
	var years_list = []
	var bisect_list = []

	var startYear = 1870
	var endYears = 1870 + int(years)

	while startYear <= endYears:
		years_list.append(startYear)
		startYear += 1
	for year in years_list:
		if year % 4 == 0:
			if year % 100 == 0:
				if year % 400 == 0:
					bisect_list.append(year)
				else:
					pass
			else:
				pass
		else:
			pass
			
	return bisect_list

func isBisectyear():
	if currentYear % 4 == 0:
		if currentYear % 100 == 0:
			if currentYear % 400 == 0:
				return true # For example, 2000 is a bisect year
			else:
				return false # While 1900 is not
	else:
		return false
	

func randomEvent():
	var start = 0
	var end = 100
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var event = round(rng.randf_range(start, end))
	
	if event <= 5:
		# time_now = OS.get_ticks_msec() / 1000
		
		$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "Lucky! You have found a penny!")
		logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "Lucky! You have found a penny!"))
		totalCash += 1
		time_now = 0
	elif event == 6:
		# time_now = OS.get_ticks_msec() / 1000
		$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "You have been fired!")
		logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "You have been fired!"))
		currentJob = "Unemployed"
	elif event >= 7 and event <= 17:
		if currentJob == "Unemployed":
			#time_now = OS.get_ticks_msec() / 1000
			$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "You have been hired!")
			logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "You have been hired!"))
			time_now = 0
		else:
			#time_now = OS.get_ticks_msec() / 1000
			$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "Lucky! You have found a penny!")
			logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "Lucky! You have found a penny!"))
			totalCash += 1
			time_now = 0
		
	elif event >= 95:
		#time_now = OS.get_ticks_msec() / 1000
		$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + "Unlucky! You got robbed from your day´s wage!")
		logList.append(str("\n" + "Day "+ str(totalDays) + " : " + "Unlucky! You got robbed from your day´s wage!"))
		totalCash -= wage
		time_now = 0
		
func unemployment():
	if wage != 0:
		wage = 0
		
func hired():
	currentJob = "Asembly Line Worker"
	
func lifeExpectancy_func():
	var start = 35
	var end = 80
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var lifeTime = round(rng.randf_range(start, end))
	return lifeTime - 12

func weekdayCalc(days):
	print("weekday is active")
	var sundays = days / 7
	print(sundays)
	for i in range(days):
		totalCash += wage
		health -= 0.5
		lifeExpectancy_var -= 1
		buttonCount += 1
		totalDays += 1
		randomEvent()
		outTemp = temperature()
		weather = weather(outTemp)
		climateLog.append("Today´s weather is: " + str(weather) + " " + str(outTemp) + "°C")
		
	if days == 7 or days == 30:
		if totalDays % 7 == 0 or totalDays % 30 == 0:
			var sunday_wages = wage * sundays # to account for not working on sundays
			print(sunday_wages)
			totalCash -= sunday_wages
			$innerPanel/eventLog.add_item("No working at sundays.")
	elif days == 1 and totalDays % 7 == 0:
		print("Sunday")
		var sunday_wages = wage
		print(sunday_wages)
		totalCash -= sunday_wages

func climate():
	var temperature = temperature()
	var weather = weather(temperature)

# The function below is a rudimentary statistical model for wheather
# All values are more or less arbitrary based on personal feelings >
# > and anecdotal experience (ergo, an asspull).
func weather(temp):
	var start = 0
	var end = 100
	
	# If temperatures are below zero
	if temp <= 0:
		weatherStatus = "Cold"
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var weatherNum = round(rng.randf_range(start, end))
		if weatherNum <= 5:
			return "Light Rain (Overcast)"
		elif weatherNum <= 20 and weatherNum > 5:
			return "Rainy"
		elif weatherNum <= 40 and weatherNum > 20:
			return "Heavy Rain"
		elif weatherNum <= 85 and weatherNum > 40:
			return "Light Snow"
		elif weatherNum <= 90 and weatherNum > 85:
			return "Snowy"
		elif weatherNum <= 98 and weatherNum > 90:
			return "Snowstorm"
		elif weatherNum <= 100 and weatherNum > 98:
			return "Sunny"
		
	# If temperatures are mildly cold
	elif temp >= 1 and temp <= 14 :
		weatherStatus = "Mild"
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var weatherNum = round(rng.randf_range(start, end))
		if weatherNum <= 5:
			return "Light Rain (Overcast)"
		elif weatherNum <= 20 and weatherNum > 5:
			return "Rainy"
		elif weatherNum <= 40 and weatherNum > 20:
			return "Heavy Rain"
		elif weatherNum <= 85 and weatherNum > 40:
			return "Light snow"
		elif weatherNum <= 90 and weatherNum > 85:
			return "Snowy"
		elif weatherNum <= 98 and weatherNum > 90:
			return "Heavy now"
		elif weatherNum <= 100 and weatherNum > 98:
			return "Sunny"
		
		
	# If temperatures are hot
	elif temp >= 15:
		weatherStatus = "Hot"
		var rng = RandomNumberGenerator.new()
		rng.randomize()
		var weatherNum = round(rng.randf_range(start, end))
		if weatherNum <= 3:
			return "Snowy"
		elif weatherNum <= 7 and weatherNum > 3:
			return "Light Snow"
		elif weatherNum <= 20 and weatherNum > 7:
			return "Sunny"
		elif weatherNum <= 70 and weatherNum > 20:
			return "Light Rain (Overcast)"
		elif weatherNum <= 90 and weatherNum > 70:
			return "Rainy"
		elif weatherNum <= 99 and weatherNum > 90:
			return "Heavy Rain"
		elif weatherNum <= 100 and weatherNum > 99:
			return "Snowtorm"
	
	else:
		weather(outTemp)

func temperature():
	var start = -10
	var end = 10
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var temp = round(rng.randf_range(start, end))
	
	return temp

func add_day(num):
	monthDay += num
	
	# Check for end of month
	if monthDay > 31 and currentMonth == "January":
		monthDay = 1
		currentMonth = "February"
	elif monthDay > 28 and currentMonth == "February":
		if isLeapYear == false:
			monthDay = 1
			currentMonth = "March"
		else:
			if monthDay > 29 and currentMonth == "February":
				monthDay = 1
				currentMonth = "March"
	elif monthDay > 31 and currentMonth == "March":
		monthDay = 1
		currentMonth = "April"
	elif monthDay > 30 and currentMonth == "April":
		monthDay = 1
		currentMonth = "May"
	elif monthDay > 31 and currentMonth == "May":
		monthDay = 1
		currentMonth = "June"
	elif monthDay > 30 and currentMonth == "June":
		monthDay = 1
		currentMonth = "July"
	elif monthDay > 31 and currentMonth == "July":
		monthDay = 1
		currentMonth = "August"
	elif monthDay > 31 and currentMonth == "August":
		monthDay = 1
		currentMonth = "September"
	elif monthDay > 30 and currentMonth == "September":
		monthDay = 1
		currentMonth = "October"
	elif monthDay > 31 and currentMonth == "October":
		monthDay = 1
		currentMonth = "November"
	elif monthDay > 30 and currentMonth == "November":
		monthDay = 1
		currentMonth = "December"
	elif monthDay > 31 and currentMonth == "December":
		monthDay = 1
		currentMonth = "January"
		currentYear += 1

func gameOver():
	var score = totalCash
	$innerPanel/eventLog.add_item("Your score is: " + str(score))
	$innerPanel/eventLog.add_item("You have died after " + str(totalDays) + " days.")
	$innerPanel/eventLog.add_item("To start over, press the restart button.")
	logList.append(str("\n" + "Your score is: " + str(score)))
	logList.append(str("\n" + "You have died after " + str(totalDays) + " days."))

func _on_clickBTN_pressed():
	weekdayCalc(1)
	add_day(1)
	
func _on_clickWeekBTN_button_up():
	weekdayCalc(7)
	add_day(7)
	
func _on_clickMonthBTN_button_up():
	weekdayCalc(30)
	add_day(30)
	
func _on_CheckButton_toggled(button_pressed):
	if button_pressed == false:
		overtime_toggled = false
	else:
		overtime_toggled = true
		#time_now = OS.get_ticks_msec() / 1000
		$innerPanel/eventLog.add_item("Day "+ str(totalDays) + " : " + " You have decided to go on overtime.")
		logList.append(str("\n" + "Day "+ str(totalDays) + " : " + " You have decided to go on overtime.s"))

func _on_logButton_button_up():
	print(logList)

func _on_restartBTN_pressed():
	get_tree().reload_current_scene()

func _on_quitBTN_pressed():	
	get_tree().quit()

func _on_testButton_button_up():
	add_day(1)
	var format = str(currentMonth) + ", " + str(monthDay) + " " + str(currentYear)
	print(format)
