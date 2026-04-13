import "@hotwired/turbo-rails"
import "controllers"

const THEME_KEY = "theme-preference"

function applyTheme(theme, button) {
  const isDark = theme === "dark"
  document.body.classList.toggle("dark-mode", isDark)
  document.documentElement.classList.toggle("dark-mode", isDark)

  if (!button) return

  button.setAttribute("aria-pressed", String(isDark))
  button.innerHTML = isDark
    ? '<i class="fas fa-sun"></i>'
    : '<i class="fas fa-moon"></i>'
}

function applyStoredTheme() {
  const storedTheme = localStorage.getItem(THEME_KEY)
  if (storedTheme) {
    applyTheme(storedTheme, document.getElementById("theme-toggle"))
  }
}

function initThemeToggle() {
  const button = document.getElementById("theme-toggle")
  const storedTheme = localStorage.getItem(THEME_KEY)

  // If stored theme exists, use it; otherwise keep current theme state
  if (storedTheme) {
    applyTheme(storedTheme, button)
  } else {
    // Apply theme based on current body class (set by immediate IIFE) or system preference
    const currentIsDark = document.body.classList.contains("dark-mode")
    const prefersDark = window.matchMedia("(prefers-color-scheme: dark)").matches
    const initialTheme = currentIsDark ? "dark" : (prefersDark ? "dark" : "light")
    applyTheme(initialTheme, button)
  }

  if (!button) return

  button.onclick = () => {
    const nextTheme = document.body.classList.contains("dark-mode") ? "light" : "dark"
    localStorage.setItem(THEME_KEY, nextTheme)
    applyTheme(nextTheme, button)
  }
}

function initFilterPanels() {
  const toggles = document.querySelectorAll(".filter-toggle")
  const panels = document.querySelectorAll(".filter-panel")

  if (!toggles.length) return

  toggles.forEach((toggle) => {
    toggle.addEventListener("click", (event) => {
      event.preventDefault()
      const targetId = toggle.dataset.target
      const targetPanel = document.getElementById(targetId)

      panels.forEach((panel) => {
        if (panel !== targetPanel) panel.classList.add("hidden")
      })

      if (targetPanel) targetPanel.classList.toggle("hidden")
    })
  })

  document.addEventListener("click", (event) => {
    const insidePanel = event.target.closest(".filter-panel")
    const insideToggle = event.target.closest(".filter-toggle")

    if (!insidePanel && !insideToggle) {
      panels.forEach((panel) => panel.classList.add("hidden"))
    }
  })
}

function initFormEnterSubmit() {
  const forms = document.querySelectorAll("form")
  forms.forEach((form) => {
    const inputs = form.querySelectorAll("input:not([type='submit']):not([type='button']):not([type='reset'])")
    inputs.forEach((input) => {
      input.addEventListener("keydown", (e) => {
        if (e.key === "Enter") {
          e.preventDefault()
          const submitBtn = form.querySelector("input[type='submit'], button[type='submit']")
          if (submitBtn) submitBtn.click()
        }
      })
    })
  })
}

// Apply stored theme on page load (before DOM is ready) - prevents flash of wrong theme
(function() {
  const storedTheme = localStorage.getItem(THEME_KEY)
  if (storedTheme === "dark") {
    document.body.classList.add("dark-mode")
    document.documentElement.classList.add("dark-mode")
  }
})()

// Wait for DOM to be ready before initializing interactive features
document.addEventListener("DOMContentLoaded", () => {
  applyStoredTheme()
  initThemeToggle()
  initFilterPanels()
  initFormEnterSubmit()
})

// Handle Turbo page loads (for SPAs)
document.addEventListener("turbo:load", () => {
  applyStoredTheme()
  initThemeToggle()
  initFilterPanels()
  initFormEnterSubmit()
})
