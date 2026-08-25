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

        print("Scanning page for 'Send to card' buttons...")
        try:
            page.wait_for_selector(button_selector, timeout=12000)
        except Exception:
            print("Could not find any 'Send to card' buttons. Verify that you are logged in and the coupons are visible.")
            context.close()
            return

        buttons = page.query_selector_all(button_selector)
        total_buttons = len(buttons)
        print(f"Found {total_buttons} eligible coupons.")

        clipped_count = 0
        for index, button in enumerate(buttons):
            try:
                # Scroll each button into view before clicking
                button.scroll_into_view_if_needed()
                
                if button.is_enabled() and button.is_visible():
                    button.click()
                    clipped_count += 1
                    print(f"[{clipped_count}/{total_buttons}] Clicked coupon.")
                    
                    # Randomize delay slightly to simulate human timing
                    time.sleep(1.5)
            except Exception as e:
                print(f"Failed to click coupon at index {index + 1}: {e}")

        print(f"\nProcessing complete. Successfully clicked {clipped_count} coupons.")
        time.sleep(5)
        context.close()

if __name__ == "__main__":
    clip_cvs_coupons_stealth()
