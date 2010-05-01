#!/usr/bin/perl -w

use IO::Handle;
pipe(READHANDLE, WRITEHANDLE);
WRITEHANDLE->autoflush(1);
READHANDLE->autoflush(1);
if ($process_id = fork) {
    close WRITEHANDLE;
    while (defined ($text = <READHANDLE>)) {
        print $text;
    }
    close READHANDLE;
    waitpid($process_id, 0);
} else {
    close READHANDLE;
    print WRITEHANDLE "Here \n ";
    print WRITEHANDLE "is  \n";
    print WRITEHANDLE "the  \n";
    print WRITEHANDLE "text. \n\n";
    exit;
}
