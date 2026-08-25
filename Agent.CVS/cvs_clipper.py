import time
import os
from playwright.sync_api import sync_playwright

def clip_cvs_coupons_stealth():
    # Define a local folder to store temporary browser profile state
    profile_dir = os.path.join(os.getcwd(), "cvs_profile")

    with sync_playwright() as p:
        print("Launching Google Chrome with anti-detection configurations...")
        
        # Use launch_persistent_context to emulate a normal returning user
        context = p.chromium.launch_persistent_context(
            user_data_dir=profile_dir,
            headless=False,
            channel="chrome",  # Instructs Playwright to use your system's Google Chrome
            args=[
                "--disable-blink-features=AutomationControlled",  # Overrides navigator.webdriver flag
                "--start-maximized"
            ],
            ignore_default_args=["--enable-automation"],  # Prevents the "Chrome is being controlled..." banner
            no_viewport=True  # Allows the browser to open with standard screen dimensions
        )
        
        # Access the first available open page in the persistent context
        page = context.pages[0] if context.pages else context.new_page()

        target_url = (
            "https://www.cvs.com/extracare/home/alloffer?progname=extracare&linkType=coupon"
            "&id=04YTc4OWU3ZDJjYjRmZmE1NjMwNTkzZDYyZjRlN2VkMzU5MTJhNDQ1ZjAyODZlNTk0YWJhMzlhNzQ5OTU0NWNiMDQwNTQzMTAwNjM5MDIwMTAwNjI5MjQ2MzY0ODAwMDc%3D"
            "&WT.mc_id=~~WEB_TAG_TRN~~_FW~~COM_FWK_NBR~~&email_cmpgn_id=~~EMAILCAMPAIGNID~~"
        )

        print("Navigating to CVS ExtraCare page...")
        page.goto(target_url)

        # Allow user to handle authentication
        print("\n--- User Action Required ---")
        print("1. If prompted, complete any login requirements or verification checks.")
        print("2. Ensure the coupons are visible on the page.")
        print("3. Once the coupons are displayed on your screen, return to this terminal.")
        input("Press Enter here to start clipping coupons...")

        # Selector for the coupons
        button_selector = 'button:has-text("Send to card")'

        print("\nStarting dynamic page scanning and scrolling...")

        clipped_count = 0
        consecutive_no_buttons = 0
        max_scroll_attempts_without_buttons = 5

        while True:
            # 1. Fetch currently visible and unclicked "Send to card" buttons
            buttons = page.query_selector_all(button_selector)
            
            if buttons:
                consecutive_no_buttons = 0  # Reset the scroll idle counter
                print(f"Found {len(buttons)} unclipped coupon(s) on current section.")
                
                for button in buttons:
                    try:
                        # Scroll the individual button into view before clicking
                        button.scroll_into_view_if_needed()
                        
                        if button.is_enabled() and button.is_visible():
                            button.click()
                            clipped_count += 1
                            print(f"[{clipped_count}] Clicked 'Send to card'.")
                            
                            # Jittered delay to mimic human speed and protect account rate limits
                            time.sleep(1.5)
                    except Exception as e:
                        # Skip if elements become detached or dynamically update mid-loop
                        continue
            else:
                consecutive_no_buttons += 1
                print(f"No new coupons in view. (Check {consecutive_no_buttons}/{max_scroll_attempts_without_buttons})")

            # 2. Stop if we have scrolled repeatedly and seen no coupons
            if consecutive_no_buttons >= max_scroll_attempts_without_buttons:
                print("No additional coupons detected after multiple scrolling attempts.")
                break

            # 3. Check if we have hit the absolute bottom of the page
            is_at_bottom = page.evaluate(
                "window.innerHeight + window.scrollY >= document.body.scrollHeight - 100"
            )
            if is_at_bottom:
                # Do one final scan to ensure no new lazy-loaded elements popped up at the bottom
                final_check = page.query_selector_all(button_selector)
                if not final_check:
                    print("Reached the absolute bottom of the page. All coupons processed.")
                    break

            # 4. Scroll down to trigger the next batch of coupons to lazy-load
            print("Scrolling down to load more coupons...")
            page.evaluate("window.scrollBy(0, 800);")
            time.sleep(2.0)  # Wait for AJAX elements to render

        print(f"\nCompleted. Successfully clipped {clipped_count} coupons.")
        time.sleep(5)
        context.close()

if __name__ == "__main__":
    clip_cvs_coupons_stealth()
