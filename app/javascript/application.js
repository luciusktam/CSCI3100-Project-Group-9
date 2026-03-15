// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

const THEME_KEY = "theme-preference"

function applyTheme(theme, button) {
	const isDark = theme === "dark"
	document.body.classList.toggle("dark-mode", isDark)

	if (!button) return

	button.setAttribute("aria-pressed", String(isDark))
	button.innerHTML = isDark
		? '<i class="fas fa-sun"></i><span>Light</span>'
		: '<i class="fas fa-moon"></i><span>Dark</span>'
}

function initThemeToggle() {
	const button = document.getElementById("theme-toggle")
	const storedTheme = localStorage.getItem(THEME_KEY)
	const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
	const initialTheme = storedTheme || (prefersDark ? "dark" : "light")

	applyTheme(initialTheme, button)

	if (!button) return

	button.onclick = () => {
		const nextTheme = document.body.classList.contains("dark-mode") ? "light" : "dark"
		localStorage.setItem(THEME_KEY, nextTheme)
		applyTheme(nextTheme, button)
	}
}

document.addEventListener("turbo:load", initThemeToggle)
