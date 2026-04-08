<?php
$queue = "test-queue";
var_dump(filter_var($queue, FILTER_VALIDATE_URL) === false);
