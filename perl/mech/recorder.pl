#!/usr/bin/perl

    use HTTP::Proxy;
    use HTTP::Recorder;

    my $proxy = HTTP::Proxy->new();

    # create a new HTTP::Recorder object
    my $agent = new HTTP::Recorder;

    # set the log file (optional)
    $agent->file("/tmp/myfile");

    # set HTTP::Recorder as the agent for the proxy
    $proxy->agent( $agent );

    # start the proxy
    $proxy->start();

    1;
