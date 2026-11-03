# Get Your Machine Ready

You need a container runtime such as Docker, the `kubectl` command-line tool and the `astrona` command-line tool. The playgrounds and labs create a kind (Kubernetes in Docker) cluster on your machine, so the runtime must be running before you start.

The commands you use every day are `astrona run` to start a playground or a lab, `astrona submit` to grade a lab and `astrona validate` to check a lab configuration. A start can fail when the container runtime is not running or when a previous cluster still holds the ports. Stop the old environment and start again.

Keep notes on unfamiliar terms and explain why each answer follows from the teaching. If a page cannot be read, report its title and the visible problem so that maintainers can find it.
