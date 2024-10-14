---
description: Welcome to the jetlog documentation!
---

# Introduction

jetlog is a structured logging, in which log records include a message, severity level, and bound set of fields representing a key-value pairs.

jetlog provides a logger, which provides the ability to report an event (record) of interest. Typically, a logger has a record handler assigned to it. A handler is responsible to handle emitted record. It can delegate it to an external interface (like file, or stdout),  or simply ignore it.
