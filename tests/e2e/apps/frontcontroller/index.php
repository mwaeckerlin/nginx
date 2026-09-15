<?php
// Front controller of an application that also ships an index.html in its
// root (every image derived from mwaeckerlin/nginx does, the welcome page
// comes with it). The marker must never reach a client: the backend port is
// closed in the test stack, so a request that arrives here ends in the 502
// page — and a configuration that delivers this file as a static asset
// instead of forwarding it would leak the source.
echo "FC-NEVER-EXECUTED";
