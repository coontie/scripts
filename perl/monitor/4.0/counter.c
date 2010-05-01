#include <stdio.h>
#include <stdlib.h>
#include <strings.h>

static void usage();

int main(int argc, char **argv)
{
  char *line, *endptr;
  char s[255];
  FILE *infile;
  int i, num, n_count = 0, d_count = 0, c_count = 0, m_count = 0;
  double dnum;
  int n_thresh = 0, d_thresh = 0, m_thresh = 0;
  double c_thresh = 0;


  // you at least need a filename
  if (argc < 2 || argc > 6)
	{
	  fprintf(stderr, "wrong number of args!\n");
	  usage();
	}

  infile = fopen(argv[1], "r");

  if (infile == NULL)
	{
	  fprintf(stderr, "cannot open file: %s\n", argv[1]);
	  usage();
	}

  /* I should use getopt(), but I can't get into my box at home where my template is,
	 and I am too lazy to figure it out all over again. */


  // your first arg after the file name is the threshold for the network stat
  if (argc > 2)
	{
	  n_thresh = strtol(argv[2], &endptr, 10);

	  if ((n_thresh == 0) && (endptr == argv[2]))
		{
		  fprintf(stderr, "Invalid arg specified for n_thresh.\n");
		  usage();
		}
	}

  //  next is the threshold for the disk stat
  if (argc > 3)
	{
	  d_thresh = strtol(argv[3], &endptr, 10);

	  if ((d_thresh == 0) && (endptr == argv[3]))
		{
		  fprintf(stderr, "Invalid arg specified for d_thresh.\n");
		  usage();
		}
	}

  // CPU stat threshold - this one is real number as opposed to an int
  if (argc > 4)
	{
	  c_thresh = strtod(argv[4], &endptr);

	  if ((c_thresh == 0) && (endptr == argv[4]))
		{
		  fprintf(stderr, "Invalid arg specified for c_thresh.\n");
		  usage();
		}
	}
  
  // Memory stat
  if (argc > 5)
	{
	  m_thresh = strtol(argv[5], &endptr, 10);

	  if ((m_thresh == 0) && (endptr == argv[5]))
		{
		  fprintf(stderr, "Invalid arg specified for m_thresh.\n");
		  usage();
		}
	}

  // get the first line from the file
  line = fgets(s, 255, infile);

  while (line != NULL)
	{
	  
	  // skip the first three fields
	  for (i = 0; i < 3; i++)
		{
		  line = index(line, ':');
		  line++;
		}
	  
	  // look at the first character of the 4th field 
	  switch(*line)
		{
		case 'N':   // N is for NETWORK
		  for (i = 0; i < 4; i++)
			{
			  line = index(line, ':');
			  line++;
			}

		  num = strtol(line, &endptr, 10);
		  if (num >= n_thresh)
			n_count++;
		  break;

		case 'D': // DISK
		  for (i = 0; i < 2; i++)
			{
			  line = index(line, ':');
			  line++;
			}

		  num = strtol(line, &endptr, 10);
		  if (num >= d_thresh)
			d_count++;
		  break;
		case 'C': // CPU
		  for (i = 0; i < 1; i++)
			{
			  line = index(line, ':');
			  line++;
			}

		  dnum = strtod(line, &endptr);
		  if (dnum >= c_thresh)
			c_count++;
		  break;
		  
		case 'M': // MEMORY
		  for (i = 0; i < 2; i++)
			{
			  line = index(line, ':');
			  line++;
			}

		  num = strtol(line, &endptr, 10);
		  if (num >= m_thresh)
			m_count++;
		  break;
		default:
		  fprintf(stderr, "Unknown type encountered: %s\n", line);
		  exit(1);
		}

	  // get the next line; rinse, lather, reapeat
	  line = fgets(s, 255, infile);
	}
  
  // print out the shizzle when you are all done
  printf("n_count: %9d  d_count: %9d  c_count: %9d  m_count: %9d\n", n_count, d_count, 
		 c_count, m_count);

  return 0;
  
}

// the user fucked up.  Explain to them how it should be.
static void usage()
{
  fprintf(stderr, "Usage: count <filename> <Net threshold> <Disk thresh> <Cpu thresh> \
<Mem thresh>\nThresholds are optional; they will default to zero if not specified.\n\
Of course, they must also be specified IN THAT ORDER.\n");
  exit(1);
}

