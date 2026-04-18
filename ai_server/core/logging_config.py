"""Structured JSON logging for production.

In DEBUG=True mode we keep a plain formatter so local dev stays readable.
Otherwise the root logger is reconfigured to emit one JSON object per line
so logs ship cleanly to Loki / CloudWatch / ELK without parsing gymnastics.

Request-scoped fields (request_id, user_id, store_id, endpoint, duration_ms)
are carried through a contextvar populated by middleware in main.py.
"""

from __future__ import annotations

import contextvars
import logging
import sys
from typing import Any

_request_context: contextvars.ContextVar[dict[str, Any]] = contextvars.ContextVar(
    "request_context", default={}
)


def set_request_context(**fields: Any) -> None:
    current = dict(_request_context.get())
    current.update({k: v for k, v in fields.items() if v is not None})
    _request_context.set(current)


def reset_request_context() -> None:
    _request_context.set({})


def get_request_context() -> dict[str, Any]:
    return dict(_request_context.get())


class _ContextFilter(logging.Filter):
    """Inject request-scoped fields into every record."""

    def filter(self, record: logging.LogRecord) -> bool:
        for key, value in _request_context.get().items():
            if not hasattr(record, key):
                setattr(record, key, value)
        return True


def configure_logging(debug: bool) -> None:
    root = logging.getLogger()
    for handler in list(root.handlers):
        root.removeHandler(handler)

    level = logging.DEBUG if debug else logging.INFO
    root.setLevel(level)

    handler = logging.StreamHandler(sys.stdout)
    handler.addFilter(_ContextFilter())

    if debug:
        handler.setFormatter(
            logging.Formatter(
                "%(asctime)s %(levelname)s %(name)s - %(message)s"
            )
        )
    else:
        try:
            from pythonjsonlogger import jsonlogger

            formatter = jsonlogger.JsonFormatter(
                "%(asctime)s %(levelname)s %(name)s %(message)s",
                rename_fields={"asctime": "timestamp", "levelname": "level"},
                json_ensure_ascii=False,
            )
            handler.setFormatter(formatter)
        except Exception:
            handler.setFormatter(
                logging.Formatter(
                    "%(asctime)s %(levelname)s %(name)s - %(message)s"
                )
            )

    root.addHandler(handler)
