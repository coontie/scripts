#!/usr/bin/perl -w

use strict;
use Tk;
use Tk::LabEntry;
use Tk::Pane;
use AI::FuzzyInference;

use constant PI => 3.1415927;
use constant G  => 9.81;

my $halfLenRod   = 5;
my $timeStep     = 0.05;

my $thRod;    # between -30 and 30 degrees.
my $velBall;  # ball's velocity. From -15 .. 15 m/s
my $posBall;  # ball's position. From -5 .. 5 m
my $dTheta;
my $time = 0;

# initialize.
$thRod   = -10;
$velBall = -2;
$posBall = 4;
$dTheta  = 0;

# create the FIS.
my $fis = new AI::FuzzyInference;

# define the input variables.
$fis->inVar(posBall  => -5, 5,
	    far_left  => [-4, 1, -2, 0],
	    left      => [-4, 0, -2, 1, 0, 0],
	    center    => [-2, 0, 0, 1, 2, 0],
	    right     => [0, 0, 2, 1, 4, 0],
	    far_right => [2, 0, 4, 1],
	    );

$fis->inVar(velBall   => -15, 15,
	    fast_neg   => [-9, 1, -3, 0],
	    medium_neg => [-9, 0, -3, 1, 0, 0],
	    slow       => [-3, 0, 0, 1, 3, 0],
	    medium_pos => [0, 0, 3, 1, 9, 0],
	    fast_pos   => [3, 0, 9, 1],
	    );

$fis->inVar(thRod      => -30, 30,
	    large_neg  => [-20, 1, -10, 0],
	    medium_neg => [-20, 0, -10, 1, 0, 0],
	    small      => [-10, 0, 0, 1, 10, 0],
	    medium_pos => [0, 0, 10, 1, 20, 0],
	    large_pos  => [10, 0, 20, 1],
	    );

# define the output variable.
$fis->outVar(dTheta    => -10, 10,
	     large_neg => [-8, 1, -4, 0],
	     small_neg => [-8, 0, -4, 1, 0, 0],
	     zero      => [-4, 0, 0, 1, 4, 0],
	     small_pos => [0, 0, 4, 1, 8, 0],
	     large_pos => [4, 0, 8, 1],
	     );

# now define the rules.
$fis->addRule(
	      'posBall=far_left     & velBall=fast_neg     & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=fast_neg     & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=fast_neg     & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=fast_neg     & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=fast_neg     & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=far_left     & velBall=medium_neg   & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=medium_neg   & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=medium_neg   & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=medium_neg   & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=medium_neg   & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=far_left     & velBall=slow         & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=slow         & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=slow         & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=slow         & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=slow         & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=far_left     & velBall=medium_pos   & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=far_left     & velBall=medium_pos   & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=medium_pos   & thRod=small       ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=medium_pos   & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=medium_pos   & thRod=large_pos   ' => 'dTheta=small_neg',

	      'posBall=far_left     & velBall=fast_pos     & thRod=large_neg   ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=fast_pos     & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=far_left     & velBall=fast_pos     & thRod=small       ' => 'dTheta=zero',
	      'posBall=far_left     & velBall=fast_pos     & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=far_left     & velBall=fast_pos     & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=left         & velBall=fast_neg     & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=fast_neg     & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=fast_neg     & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=fast_neg     & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=left         & velBall=fast_neg     & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=left         & velBall=medium_neg   & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=medium_neg   & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=medium_neg   & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=medium_neg   & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=left         & velBall=medium_neg   & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=left         & velBall=slow         & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=slow         & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=slow         & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=slow         & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=left         & velBall=slow         & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=left         & velBall=medium_pos   & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=left         & velBall=medium_pos   & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=medium_pos   & thRod=small       ' => 'dTheta=zero',
	      'posBall=left         & velBall=medium_pos   & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=left         & velBall=medium_pos   & thRod=large_pos   ' => 'dTheta=small_neg',

	      'posBall=left         & velBall=fast_pos     & thRod=large_neg   ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=fast_pos     & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=left         & velBall=fast_pos     & thRod=small       ' => 'dTheta=zero',
	      'posBall=left         & velBall=fast_pos     & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=left         & velBall=fast_pos     & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=center       & velBall=fast_neg     & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=center       & velBall=fast_neg     & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=center       & velBall=fast_neg     & thRod=small       ' => 'dTheta=large_pos',
	      'posBall=center       & velBall=fast_neg     & thRod=medium_pos  ' => 'dTheta=small_pos',
	      'posBall=center       & velBall=fast_neg     & thRod=large_pos   ' => 'dTheta=small_pos',

	      'posBall=center       & velBall=medium_neg   & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=center       & velBall=medium_neg   & thRod=medium_neg  ' => 'dTheta=large_pos',
	      'posBall=center       & velBall=medium_neg   & thRod=small       ' => 'dTheta=small_pos',
	      'posBall=center       & velBall=medium_neg   & thRod=medium_pos  ' => 'dTheta=small_pos',
	      'posBall=center       & velBall=medium_neg   & thRod=large_pos   ' => 'dTheta=zero',

	      'posBall=center       & velBall=slow         & thRod=large_neg   ' => 'dTheta=small_pos',
	      'posBall=center       & velBall=slow         & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=center       & velBall=slow         & thRod=small       ' => 'dTheta=zero',
	      'posBall=center       & velBall=slow         & thRod=medium_pos  ' => 'dTheta=zero',
	      'posBall=center       & velBall=slow         & thRod=large_pos   ' => 'dTheta=small_neg',

	      'posBall=center       & velBall=medium_pos   & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=center       & velBall=medium_pos   & thRod=medium_neg  ' => 'dTheta=small_neg',
	      'posBall=center       & velBall=medium_pos   & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=center       & velBall=medium_pos   & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=center       & velBall=medium_pos   & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=center       & velBall=fast_pos     & thRod=large_neg   ' => 'dTheta=small_neg',
	      'posBall=center       & velBall=fast_pos     & thRod=medium_neg  ' => 'dTheta=small_neg',
	      'posBall=center       & velBall=fast_pos     & thRod=small       ' => 'dTheta=large_neg',
	      'posBall=center       & velBall=fast_pos     & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=center       & velBall=fast_pos     & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=right        & velBall=fast_neg     & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=right        & velBall=fast_neg     & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=right        & velBall=fast_neg     & thRod=small       ' => 'dTheta=zero',
	      'posBall=right        & velBall=fast_neg     & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=right        & velBall=fast_neg     & thRod=large_pos   ' => 'dTheta=small_neg',

	      'posBall=right        & velBall=medium_neg   & thRod=large_neg   ' => 'dTheta=small_pos',
	      'posBall=right        & velBall=medium_neg   & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=right        & velBall=medium_neg   & thRod=small       ' => 'dTheta=zero',
	      'posBall=right        & velBall=medium_neg   & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=right        & velBall=medium_neg   & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=right        & velBall=slow         & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=right        & velBall=slow         & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=right        & velBall=slow         & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=right        & velBall=slow         & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=right        & velBall=slow         & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=right        & velBall=medium_pos   & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=right        & velBall=medium_pos   & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=right        & velBall=medium_pos   & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=right        & velBall=medium_pos   & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=right        & velBall=medium_pos   & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=right        & velBall=fast_pos     & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=right        & velBall=fast_pos     & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=right        & velBall=fast_pos     & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=right        & velBall=fast_pos     & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=right        & velBall=fast_pos     & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=far_right    & velBall=fast_neg     & thRod=large_neg   ' => 'dTheta=large_pos',
	      'posBall=far_right    & velBall=fast_neg     & thRod=medium_neg  ' => 'dTheta=small_pos',
	      'posBall=far_right    & velBall=fast_neg     & thRod=small       ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=fast_neg     & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=far_right    & velBall=fast_neg     & thRod=large_pos   ' => 'dTheta=small_neg',

	      'posBall=far_right    & velBall=medium_neg   & thRod=large_neg   ' => 'dTheta=small_pos',
	      'posBall=far_right    & velBall=medium_neg   & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=medium_neg   & thRod=small       ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=medium_neg   & thRod=medium_pos  ' => 'dTheta=small_neg',
	      'posBall=far_right    & velBall=medium_neg   & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=far_right    & velBall=slow         & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=slow         & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=slow         & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=far_right    & velBall=slow         & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=far_right    & velBall=slow         & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=far_right    & velBall=medium_pos   & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=medium_pos   & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=medium_pos   & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=far_right    & velBall=medium_pos   & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=far_right    & velBall=medium_pos   & thRod=large_pos   ' => 'dTheta=large_neg',

	      'posBall=far_right    & velBall=fast_pos     & thRod=large_neg   ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=fast_pos     & thRod=medium_neg  ' => 'dTheta=zero',
	      'posBall=far_right    & velBall=fast_pos     & thRod=small       ' => 'dTheta=small_neg',
	      'posBall=far_right    & velBall=fast_pos     & thRod=medium_pos  ' => 'dTheta=large_neg',
	      'posBall=far_right    & velBall=fast_pos     & thRod=large_pos   ' => 'dTheta=large_neg',
	      );

drawGUI();

MainLoop;

# this subroutine calculates the new values of the ball's position
# and velocity after a period of time $timeStep.
# Friction is not modeled.
sub calcNewData {
  my $acc  = G * sin ($thRod * PI / 180);
  my $Vnew = $velBall + $acc * $timeStep;
  my $dist = $velBall * $timeStep + 0.5 * $acc * $timeStep * $timeStep;

  $velBall  = $Vnew;
  $posBall += $dist;

  $velBall =  15 if $velBall >  15;
  $velBall = -15 if $velBall < -15;

  $time += $timeStep;
}

# This sub draws the gui.
sub drawGUI {
   my $mw = new MainWindow;

   my $canvas = $mw->Canvas(qw/-bg black -height 400 -width 600/)->pack;

   $canvas->createLine(0, 0, 0, 0,   qw/-width 2 -fill white -tags ROD/);
   $canvas->createOval(0, 0, 50, 50, qw/-fill green -tags BALL/);

   my $f = $mw->Frame->pack(qw/-fill x/);

   my @rules;

   my $id;

   $f->Button(-text    => 'run',
	      -command => sub {
		$id = $canvas->repeat(100 => sub {
					# update the ball's data.
					calcNewData();

					# check for termination conditions.

					# stop if ball is almost stationary and the rod
					# is almost flat.
					if (abs($velBall) < 0.005 && abs($thRod) < 0.001) {
					  print "Simulation ended.\n";
					  $canvas->afterCancel($id);
					  return;
					}

					# stop if ball fell off the rod.
					if ($posBall > $halfLenRod or $posBall < -$halfLenRod) {
					  print "Ball fell off the rod!\n";
					  $canvas->afterCancel($id);
					  return;
					}

					# compute the new angle of the rod.
					$fis->compute(posBall => $posBall,
						      velBall => $velBall,
						      thRod   => $thRod);

					$dTheta = $fis->value('dTheta');
					$thRod += $dTheta;

					$thRod = -30 if $thRod < -30;
					$thRod =  30 if $thRod >  30;

					# don't do this.
					# I'm peaking inside the $fis object.
					for my $i (@{$fis->{FIRED}}) {
					    $rules[$i->[0]] = $i->[1];
					}
					$mw->update;
					# update our drawing.
					updateCanvas($canvas);
				      });
	      })->pack(qw/-side left -ipadx 10/);

   $f->Button(-text    => 'pause',
	      -command => sub { $canvas->afterCancel($id) })->pack(qw/-side left/);

   $f->LabEntry(-label => 'Ball Pos',
		-textvariable => \$posBall,
	       )->pack(qw/-side left -padx 10/);

   $f->LabEntry(-label => 'Ball Speed',
		-textvariable => \$velBall,
	       )->pack(qw/-side left -padx 10/);

   $f->LabEntry(-label => 'Rod Angle',
		-textvariable => \$thRod,
	       )->pack(qw/-side left -padx 10/);

   $f->LabEntry(-label => 'dTheta',
		-textvariable => \$dTheta,
	       )->pack(qw/-side left -padx 10/);

   my $f2 = $mw->Scrolled(qw/Pane -sticky new/)->pack(qw/-fill both -expand 1/);

   my $ind = 0;
   for my $r (@{$fis->{RULES}}) { # peek inside
       $f2->LabEntry(-label => "$r->[0] => $r->[1]",
		     -textvariable => \$rules[$ind],
		     -labelPack => [qw/-side right/],
		     )->pack(qw/-fill none -side top -anchor w/);
       $ind++;
   }

   updateCanvas($canvas);
}

# This subroutine draws the rod at its current angle, and
# the ball at its current position.
sub updateCanvas {
  my $c = shift;

  my $ly = 200;
  my $dy = int(40 * $halfLenRod * tan(PI * $thRod / 180));
  $c->coords(ROD => 100, $ly - $dy, 500, $ly + $dy);

  my $by = 150 + $posBall * $dy / $halfLenRod;

  my $bx = 100 + (5 + $posBall) * 40;
  $c->coords(BALL => $bx - 25, $by, $bx + 25, $by + 50);
}

# tangent sub.
sub tan { sin($_[0]) / cos($_[0])  }


