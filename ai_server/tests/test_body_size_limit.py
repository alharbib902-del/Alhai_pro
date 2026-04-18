"""LimitBodySizeMiddleware regression tests - اختبارات حد حجم الجسم.

The previous BaseHTTPMiddleware + Content-Length-only guard was defeated by
(a) outer middleware that buffered the body first, and (b) chunked transfer
encoding that omits Content-Length. These tests exercise the ASGI middleware
directly with synthesized scope / receive / send so the assertions reflect the
raw contract, not TestClient behaviour.
"""

from __future__ import annotations

import pytest

from main import LimitBodySizeMiddleware


MAX = 1024  # 1 KiB for tests


async def _collect(send_messages: list[dict]):
    async def _send(msg):
        send_messages.append(msg)
    return _send


def _scope(method: str = "POST", headers: list | None = None) -> dict:
    return {
        "type": "http",
        "method": method,
        "path": "/ai/chat",
        "headers": headers or [],
    }


async def _app_ok(scope, receive, send):
    """A trivial downstream ASGI app that reads the full body then 200s."""
    body = b""
    more = True
    while more:
        msg = await receive()
        if msg["type"] == "http.disconnect":
            return
        body += msg.get("body", b"")
        more = msg.get("more_body", False)
    send_msgs = {
        "start": {"type": "http.response.start", "status": 200,
                  "headers": [(b"content-length", str(len(body)).encode())]},
        "body": {"type": "http.response.body", "body": body},
    }
    await send(send_msgs["start"])
    await send(send_msgs["body"])


@pytest.mark.asyncio
async def test_rejects_oversize_content_length_before_reading_body():
    """Content-Length fast-path: downstream app never runs."""
    app_calls = []

    async def record_app(scope, receive, send):
        app_calls.append(scope)

    mw = LimitBodySizeMiddleware(record_app, max_bytes=MAX)

    sent: list[dict] = []

    async def send(msg):
        sent.append(msg)

    async def receive():  # pragma: no cover -- must not be called
        raise AssertionError("receive() called despite oversize Content-Length")

    headers = [(b"content-length", str(MAX + 1).encode())]
    await mw(_scope(headers=headers), receive, send)

    assert app_calls == []
    assert sent[0]["type"] == "http.response.start"
    assert sent[0]["status"] == 413


@pytest.mark.asyncio
async def test_rejects_chunked_body_exceeding_limit():
    """No Content-Length, chunked (more_body=True) stream exceeds max_bytes.

    Regression for the Transfer-Encoding: chunked bypass -- the previous guard
    only inspected the Content-Length header and let chunked bodies through
    unchecked.
    """
    app_calls = []

    async def record_app(scope, receive, send):  # pragma: no cover -- must not run
        app_calls.append(scope)

    mw = LimitBodySizeMiddleware(record_app, max_bytes=MAX)

    # Stream 4 chunks of 600 bytes == 2400 total, > MAX.
    chunks = [
        {"type": "http.request", "body": b"A" * 600, "more_body": True},
        {"type": "http.request", "body": b"B" * 600, "more_body": True},
        {"type": "http.request", "body": b"C" * 600, "more_body": True},
        {"type": "http.request", "body": b"D" * 600, "more_body": False},
    ]
    iterator = iter(chunks)

    async def receive():
        return next(iterator)

    sent: list[dict] = []

    async def send(msg):
        sent.append(msg)

    # No content-length header -- chunked.
    await mw(_scope(headers=[]), receive, send)

    assert app_calls == []
    assert sent[0]["status"] == 413


@pytest.mark.asyncio
async def test_under_limit_replays_body_to_downstream_app():
    payload = b"hello chunked"
    chunks = [
        {"type": "http.request", "body": payload[:5], "more_body": True},
        {"type": "http.request", "body": payload[5:], "more_body": False},
    ]
    iterator = iter(chunks)

    async def receive():
        return next(iterator)

    mw = LimitBodySizeMiddleware(_app_ok, max_bytes=MAX)
    sent: list[dict] = []

    async def send(msg):
        sent.append(msg)

    await mw(_scope(headers=[]), receive, send)

    # Downstream echoed the full body -> replay reconstruction worked.
    assert sent[0]["type"] == "http.response.start"
    assert sent[0]["status"] == 200
    assert sent[1]["body"] == payload


@pytest.mark.asyncio
async def test_lifespan_and_get_pass_through():
    calls = []

    async def record_app(scope, receive, send):
        calls.append(scope["type"])

    mw = LimitBodySizeMiddleware(record_app, max_bytes=MAX)

    async def noop_receive():
        return {"type": "lifespan.startup"}

    async def noop_send(_):
        pass

    # lifespan scope: pass through untouched.
    await mw({"type": "lifespan"}, noop_receive, noop_send)
    # GET (no body): pass through untouched.
    await mw(_scope(method="GET"), noop_receive, noop_send)

    assert calls == ["lifespan", "http"]


@pytest.mark.asyncio
async def test_chunked_exactly_at_limit_passes():
    """Boundary: total bytes == max_bytes is NOT rejected."""
    chunks = [
        {"type": "http.request", "body": b"X" * MAX, "more_body": False},
    ]
    iterator = iter(chunks)

    async def receive():
        return next(iterator)

    mw = LimitBodySizeMiddleware(_app_ok, max_bytes=MAX)
    sent: list[dict] = []

    async def send(msg):
        sent.append(msg)

    await mw(_scope(headers=[]), receive, send)
    assert sent[0]["status"] == 200
