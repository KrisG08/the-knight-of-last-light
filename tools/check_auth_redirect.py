"""Public route check using an intentionally invalid token; never verifies a real user."""
from urllib.request import Request, build_opener, HTTPRedirectHandler, urlopen
from urllib.error import HTTPError
from urllib.parse import urlsplit

BASE = "https://vtvvevevkhqwyemrpawy.supabase.co"
RETURN = BASE + "/functions/v1/account-confirmation"

class NoRedirect(HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

try:
    response = build_opener(NoRedirect).open(
        BASE + "/auth/v1/verify?type=signup&token=" + "0" * 64, timeout=25
    )
except HTTPError as error:
    response = error

location = response.headers.get("Location", "")
target = urlsplit(location)
print("Confirmation return:", target.scheme, target.hostname, target.path)
assert target.scheme == "https" and target.hostname == urlsplit(BASE).hostname
assert target.path == "/functions/v1/account-confirmation", "Confirmation still returns to an incorrect/unreachable page"
page = urlopen(Request(RETURN, headers={"Accept-Language": "bg"}), timeout=25)
assert page.status == 200
assert page.url == RETURN + "?view=return#last-light", "Session/error fragment must be replaced with a fixed fragment"
assert "ВЪРНЕТЕ СЕ В ИГРАТА" in page.read().decode("utf-8")
assert page.headers.get("Cache-Control") == "no-store"
print("Public confirmation redirect and return page: PASS (invalid-token probe only)")
