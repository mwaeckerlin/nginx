<?php
// Exists only so the request passes try_files and reaches fastcgi_pass;
// the backend port is closed, so the answer must be the 502 error page.
echo "NEVER-EXECUTED\n";
