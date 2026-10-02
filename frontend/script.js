(function () {
  "use strict";

  // Paste the deployed Google Apps Script /exec URL here after deployment.
  var GOOGLE_SHEETS_ENDPOINT = "";
  var menuToggle = document.getElementById("menuToggle");
  var primaryNav = document.getElementById("primaryNav");
  var inquiryForm = document.getElementById("inquiryForm");
  var formStatus = document.getElementById("formStatus");
  var navLinks = Array.prototype.slice.call(document.querySelectorAll(".nav-links a[href^='#']"));
  var sections = Array.prototype.slice.call(document.querySelectorAll("main section[id]"));

  function closeMenu() {
    if (!menuToggle || !primaryNav) {
      return;
    }

    menuToggle.classList.remove("is-open");
    primaryNav.classList.remove("is-open");
    menuToggle.setAttribute("aria-expanded", "false");
    menuToggle.setAttribute("aria-label", "Open navigation menu");
  }

  function toggleMenu() {
    if (!menuToggle || !primaryNav) {
      return;
    }

    var isOpen = primaryNav.classList.toggle("is-open");
    menuToggle.classList.toggle("is-open", isOpen);
    menuToggle.setAttribute("aria-expanded", String(isOpen));
    menuToggle.setAttribute("aria-label", isOpen ? "Close navigation menu" : "Open navigation menu");
  }

  if (menuToggle) {
    menuToggle.addEventListener("click", toggleMenu);
  }

  navLinks.forEach(function (link) {
    link.addEventListener("click", closeMenu);
  });

  document.addEventListener("click", function (event) {
    if (!primaryNav || !menuToggle || !primaryNav.classList.contains("is-open")) {
      return;
    }

    if (!primaryNav.contains(event.target) && !menuToggle.contains(event.target)) {
      closeMenu();
    }
  });

  document.addEventListener("keydown", function (event) {
    if (event.key === "Escape") {
      closeMenu();
    }
  });

  window.addEventListener("resize", function () {
    if (window.innerWidth > 820) {
      closeMenu();
    }
  });

  var prefersReducedMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;
  var revealItems = Array.prototype.slice.call(document.querySelectorAll(".reveal"));

  if (prefersReducedMotion || !("IntersectionObserver" in window)) {
    revealItems.forEach(function (item) {
      item.classList.add("active");
    });
  } else {
    var revealObserver = new IntersectionObserver(function (entries, observer) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) {
          entry.target.classList.add("active");
          observer.unobserve(entry.target);
        }
      });
    }, { threshold: 0.12, rootMargin: "0px 0px -35px" });

    revealItems.forEach(function (item) {
      revealObserver.observe(item);
    });
  }

  if ("IntersectionObserver" in window && sections.length && navLinks.length) {
    var sectionObserver = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting) {
          return;
        }

        navLinks.forEach(function (link) {
          link.classList.toggle("is-active", link.getAttribute("href") === "#" + entry.target.id);
        });
      });
    }, { rootMargin: "-30% 0px -60%", threshold: 0 });

    sections.forEach(function (section) {
      sectionObserver.observe(section);
    });
  }

  if (inquiryForm && formStatus) {
    inquiryForm.addEventListener("submit", function (event) {
      event.preventDefault();
      formStatus.classList.remove("is-error");

      if (!inquiryForm.checkValidity()) {
        formStatus.textContent = "Please complete the required fields before continuing.";
        formStatus.classList.add("is-error");
        inquiryForm.reportValidity();
        return;
      }

      var data = new FormData(inquiryForm);
      var submitButton = inquiryForm.querySelector("button[type='submit']");
      var subject = "Project inquiry from " + (data.get("name") || "a new contact");
      var body = [
        "Name: " + (data.get("name") || ""),
        "Email: " + (data.get("email") || ""),
        "Phone: " + (data.get("phone") || "Not provided"),
        "Company: " + (data.get("company") || "Not provided"),
        "Project type: " + (data.get("projectType") || ""),
        "Budget range: " + (data.get("budget") || ""),
        "",
        "Project details:",
        data.get("message") || ""
      ].join("\n");

      if (GOOGLE_SHEETS_ENDPOINT) {
        var sheetPayload = new URLSearchParams();
        data.forEach(function (value, key) {
          sheetPayload.append(key, value);
        });

        if (submitButton) {
          submitButton.disabled = true;
        }

        formStatus.textContent = "Sending your inquiry...";
        fetch(GOOGLE_SHEETS_ENDPOINT, {
          method: "POST",
          mode: "no-cors",
          body: sheetPayload
        }).then(function () {
          formStatus.textContent = "Thanks. Your inquiry has been received.";
          inquiryForm.reset();
          if (submitButton) {
            submitButton.disabled = false;
          }
        }).catch(function () {
          formStatus.textContent = "We could not save the inquiry. Please try again or email us directly.";
          formStatus.classList.add("is-error");
          if (submitButton) {
            submitButton.disabled = false;
          }
        });
        return;
      }

      formStatus.textContent = "Opening your email app with the inquiry ready to send.";
      window.location.href = "mailto:abhishekkotharkar01@gmail.com?subject=" + encodeURIComponent(subject) + "&body=" + encodeURIComponent(body);
    });
  }
}());
