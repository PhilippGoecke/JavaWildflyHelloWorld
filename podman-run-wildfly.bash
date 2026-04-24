podman build --no-cache --rm --file Containerfile --tag wildfly:demo .
podman run --interactive --tty --publish 0.0.0.0:8080:8080 wildfly:demo
echo "browse http://localhost:8080/hello.war/index.jsp?name=Test"
