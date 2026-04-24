podman build --no-cache --rm --file Containerfile --tag wildfly:demo .
podman run --interactive --tty --publish 0.0.0.0:8080:8080 wildfly:demo
echo "browse https://localhost:8080/"
