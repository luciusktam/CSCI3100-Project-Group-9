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

// Apply stored theme immediately to prevent flash
(function () {
  const storedTheme = localStorage.getItem(THEME_KEY)
  if (storedTheme === "dark") {
    document.body.classList.add("dark-mode")
    document.documentElement.classList.add("dark-mode")
  }
})()

// Theme toggle with event delegation (handles DOM replacements)
document.addEventListener("click", (event) => {
  const button = event.target.closest("#theme-toggle")
  if (!button) return

  const nextTheme = document.body.classList.contains("dark-mode") ? "light" : "dark"
  localStorage.setItem(THEME_KEY, nextTheme)
  applyTheme(nextTheme, button)
})

// Apply theme on page load - sync button state with localStorage
function syncThemeButton() {
  const button = document.getElementById("theme-toggle")
  if (!button) return

  const storedTheme = localStorage.getItem(THEME_KEY)
  const currentTheme = document.body.classList.contains("dark-mode") ? "dark" : "light"

  // If no stored theme but dark mode is active (from IIFE), set the button state
  if (!storedTheme && currentTheme === "dark") {
    applyTheme("dark", button)
  } else if (storedTheme) {
    applyTheme(storedTheme, button)
  } else {
    applyTheme("light", button)
  }
}

// Sync button immediately when DOM is ready
document.addEventListener("DOMContentLoaded", syncThemeButton)
document.addEventListener("turbo:load", syncThemeButton)

// ==================== Filter Panels ====================

// Attach filter listeners using event delegation (handles DOM replacements)
document.addEventListener("click", (event) => {
  const toggle = event.target.closest(".filter-toggle")
  if (!toggle) return

  event.preventDefault()
  event.stopPropagation()

  const targetId = toggle.dataset.target
  const targetPanel = document.getElementById(targetId)
  if (!targetPanel) return

  // Close all other panels
  document.querySelectorAll(".filter-panel").forEach((panel) => {
    if (panel !== targetPanel) panel.classList.add("hidden")
  })

  targetPanel.classList.toggle("hidden")
})

// Close panels when clicking outside (but not on clear-all link)
document.addEventListener("click", (event) => {
  const insidePanel = event.target.closest(".filter-panel")
  const insideToggle = event.target.closest(".filter-toggle")
  const isClearAll = event.target.closest(".filter-clear")

  if (!insidePanel && !insideToggle && !isClearAll) {
    document.querySelectorAll(".filter-panel").forEach((panel) =>
      panel.classList.add("hidden")
    )
  }
})

// ==================== Form Enter Key Submit ====================

function initFormEnterSubmit() {
  const form = document.querySelector("#listing-search-form")
  if (!form || form.dataset.enterInit) return
  form.dataset.enterInit = "true"

  form.addEventListener("keydown", (e) => {
    if (e.key === "Enter" && e.target.tagName !== "TEXTAREA") {
      e.preventDefault()
      form.requestSubmit()
    }
  })
}

// ==================== Initialization ====================

function initAll() {
  applyStoredTheme()
  initFormEnterSubmit()
}

// Run on DOM ready and Turbo navigations
document.addEventListener("DOMContentLoaded", initAll)
document.addEventListener("turbo:load", initAll)
document.addEventListener("turbo:frame-load", initAll)

// Reset form init flag when Turbo caches the page
document.addEventListener("turbo:before-cache", () => {
  const form = document.querySelector("#listing-search-form")
  if (form) delete form.dataset.enterInit
})
