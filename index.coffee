module.exports = (Module) ->

	weather = require "openweathermap"
	color = require "irc-colors"

	class WeatherModule extends Module
		shortName: "Weather"
		helpText:
			default: "Get the weather for a place!"
		usage:
			default: "weather [city]"

		constructor: (moduleManager) ->
			super moduleManager

			if not @getApiKey("openweathermap")?
				console.error "WeatherModule will not work without a `openweathermap` API key."

			tF = (str, mode) -> "#{str}°#{mode}"

			weatherFunction = (origin, route, mode = "metric") =>
				city = route.params.city

				dS = if mode is "metric" then "C" else "F"

				if not @getApiKey("openweathermap")?
					@reply origin, "This command needs a 'openweathermap' API Key. Add it with !set-api-key openweathermap [key]"
					return

				weather.now
					APPID: @getApiKey("openweathermap")
					q: city
					units: mode
				, (err, json) =>
					try
						if json.cod != 200
							@reply origin, json.message
							return
						console.log err, json
						conditionString = if json.weather.size is 0 then 'None' else (json.weather.map (w)-> return w.description).join ', '
						@reply origin, "Weather in #{color.bold (if json.name then json.name else city)} (#{json.coord.lat}, #{json.coord.lon}) -
							#{color.bold 'Low Temp'}: #{color.blue tF json.main.temp_min, dS},
							#{color.bold 'Temp'}: #{tF json.main.temp, dS},
							#{color.bold 'High Temp'}: #{color.red tF json.main.temp_max, dS},
							#{color.bold 'Humidity'}: #{json.main.humidity}%,
							#{color.bold 'Wind Speed'}: #{json.wind.speed}mph,
							#{color.bold 'Conditions'}: #{conditionString}"
					catch e
						@reply origin, "Could not get the weather at this point in time. Try again?"
						console.error e

			@addRoute "weather :city", weatherFunction
			@addRoute "weather-i :city", (origin, route) => weatherFunction origin, route, "imperial"

	WeatherModule
