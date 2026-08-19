# Contributing to ALiVE

Thanks for taking an interest in ALiVE. This page explains how the project is being developed at the moment and what kind of report, request or pull request is most useful, so you know what to expect when you post.

### Where development is right now

ALiVE is going through a module by module overhaul. Each module is taken in turn, audited, fixed, modernised and tested before moving on to the next. The order is planned in advance and much of the work builds on what came before, so the sequence matters.

Most of the effort goes into making what already exists work properly rather than adding new systems. Bugs in a module currently being worked on get attention quickly. Bugs elsewhere are logged and picked up when that module comes round.

### Reporting a bug

A clear bug report with an RPT log attached is the single most useful thing you can post, and by far the fastest route to a fix.

Please include:

- What you saw, and what you expected instead.
- **The RPT file** from the session where it happened. This matters more than anything else in the report, because it usually contains the actual cause.
- Which ALiVE modules were in the mission and roughly how they were set up.
- Whether it happens every time or only occasionally.
- Screenshots if the problem is something visible.

Your RPT files are in `Documents\Arma 3` (or `Documents\Arma 3 - Other Profiles\<profile>` if you use a custom profile) on Windows. Attach the file from the session where the problem occurred.

Reports with a log have gone from posted to fixed within a day, including a freeze that locked up the whole game. The same report without a log can sit unresolved for a long time, because there is nothing to trace.

### Requesting a feature

Feature requests are welcome and they do get read. Please expect them to be parked rather than actioned while the overhaul is running.

They are picked up once the module they relate to has been through its overhaul, so a slow reply is not a lack of interest. Small, well defined suggestions that fit an existing module are much more likely to be taken up than large new systems.

### Proposals that will be declined

Some things will be turned down, and it is fairer to say so up front than to leave them open indefinitely.

**Adopting another project's systems, frameworks or build tooling.** This is not a judgement on the quality of that work. ALiVE has its own architecture, its own build process and a planned direction, and taking on another design partway through an overhaul creates more work than it saves.

**Changes to how the simulation fundamentally behaves**, such as introducing a resource economy that commanders must spend from. These are direction decisions rather than features, and they are settled as part of the overhaul plan.

If you have built something you believe ALiVE should do differently, the most productive route is a focused pull request against a single module, discussed in an issue first.

### Pull requests

Pull requests are welcome. Small and focused works best: one module, one clear change, with a short description of the problem it solves.

Please open an issue first for anything substantial so it can be checked against the overhaul plan before you spend time on it. It is disappointing for everyone when good work has to be turned down because it collides with something already under way.

A few practical points:

- Match the style of the code around your change rather than introducing a new one.
- Keep unrelated tidy ups out of the same pull request.
- Say how you tested it, and mention if you have not been able to test on a dedicated server.

### Getting help

For questions about setting up or running missions, rather than a defect in ALiVE itself, the Discord is usually faster than the issue tracker.

- Wiki: https://alivewiki.com/
- Discord: https://discord.gg/KkacXFx
</content>
</invoke>
