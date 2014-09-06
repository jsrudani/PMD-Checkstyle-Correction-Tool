#!C:\Perl64\bin
#------------------------------------------------------------------------------------------------------------------------------------------
# HEADING:		PMDSolutionTool.pl	
# DESCRIPTION:	PMDSolutionTool.pl file is used to solve the checkstyle error as per the report generated by PMD tool
# AUTHOR:	 	Jigar Rudani
#				Application Modernization
#				HP Global Delivery - India
# CREATED DATE:	5 May 2013
# VERSION:		1.0	
# USAGE: 		The Script requires 2 arguments				
#            	1. CheckStyle error HTML File generated by PMD Tool
#            	2. Input Directory where source files over which PMD Solution Tool is to be run are kept
#------------------------------------------------------------------------------------------------------------------------------------------
############################################################ Global Variables Declaration Area ################################################################
use Cwd;
use Cwd 'abs_path';
%Line_Hashes = ();
$intIterator = 0;
$strFinalString = "";
$Java_File_Name = "";
$File_Boundary = "File ";
$Modified_Filename = "";
my @PrepareString = ();
my @splitValues = ();
$intSplitIterator = 0;
$intLength_PrepareString = 0;
$length_content = 0;
$Config_file_Iterator = 0;
$curr_cwd = "";
$output_dir_name = "";
$output_directory = "";
$Output_File_Dir = "";
$config_dir_name = "";
$config_directory = "";
$ConfigFileName = "";
$Input_dir_name = "";
$input_directory = "";
$InputDirName = "";
$ConfigFileNamePath = "";
$isPresent = 0;
$countJavaFiles = 0;
########################################################### Checking the parameter passed to the script ###############################################
$HTMLFile = $ARGV[0];
$Filelist = $ARGV[1];
$Number_of_arguments = $#ARGV+1;
if ($Number_of_arguments != 2)
{
        usage(255);
}
checkHtmlFile("$HTMLFile");
checkInputDir("$Filelist");
########################################################### Start of Configuration area ################################################################
$curr_cwd = getcwd();
$curr_cwd =~ s/\/+/\\/g;
print "Current working Directory ===> $curr_cwd\n";
$output_dir_name = "PMD_Output";
$output_directory = $curr_cwd . "\\" . $output_dir_name;
$Output_File_Dir = Initial_Output_Configuration($output_directory);						#$Output_File_Dir = "E:\\Vodafone UK\\Removing_Spaces_Work\\PMD_Output";

$config_dir_name = "Config_Files";
$config_directory = $curr_cwd . "\\" . $config_dir_name;
$ConfigFileNamePath = Initial_Output_Configuration($config_directory);					#$ConfigFileName = "E:\\Vodafone UK\\Removing_Spaces_Work\\Config Files\\CheckStyle.config";
$ConfigFileName = $ConfigFileNamePath . "\\CheckStyle.config";

#$Input_dir_name = "PMD_Input";
#$input_directory = $curr_cwd . "\\" . $Input_dir_name;
#$Filelist = Initial_PMD_Input_Configuration($input_directory);							# Source File Path

$tool_script_dirname = "Tool_Script";													# Folder contains HTML_PARSER.pl , PMDSolutionTool.pl and CheckStyleErrorList.txt
$html_directory = $curr_cwd . "\\" . $tool_script_dirname;
$HTML_ParserScript = Initial_Input_Configuration($html_directory,"HTML_Parser.pl");		#$HTML_ParserScript = "E:\\Vodafone UK\\Removing_Spaces_Work\\HTML_Parser.pl";
$tool_script_dirname = "Tool_Script";
$checkstyle_error_mapping = $curr_cwd . "\\" . $tool_script_dirname;
$CheckStyleMappingFile = Initial_Input_Configuration($checkstyle_error_mapping,"CheckStyle_Error_List.txt");

########################################################### End of Configuration area  ################################################################

my @HTML_Parser_args = ("$HTMLFile","$CheckStyleMappingFile","$ConfigFileName");	# Preparing parameters for HTML_Parser.pl 

############################################################ Calling Area ###########################################################

# Calling HTML_Parser.pl to create CheckStyle.config file

	local @ARGV = (@HTML_Parser_args);
	do $HTML_ParserScript;
	if ($? == 0)
	{
		Processing_Directory($Filelist);
	}

############################################################ Function Declaration Area ###########################################################
sub checkHtmlFile
{
	my($htmlfile_para) = @_;
	if ( -d "$htmlfile_para")
	{
		print "$htmlfile_para is a Directory\n";
		print "Expected ===> checkstyle_report.html file\n";
		exit 0
	}
	elsif ("$htmlfile_para" =~ m/^\./)
	{
		print "$htmlfile_para is hidden folder/file \n";
		print "Expected ===> checkstyle_report.html file\n";
		exit 0
	}
	elsif ( -f "$htmlfile_para" && "$htmlfile_para" !~ m/\.html$/) 
	{
		print "$htmlfile_para is a File but not the expected once\n";
		print "Expected ===> checkstyle_report.html file\n";
		exit 0
	}
	elsif ( -f "$htmlfile_para")
	{
	#	print "$htmlfile_para exist...!!!\n";
	}
	else
	{
		print "\n $htmlfile_para doesn't exist in current directory.\n Please provide complete absolute path\n";
		exit ;
	}
}
sub Initial_Output_Configuration
{
	my($output_directory) = @_;
	if ( -d "$output_directory")
	{
		print "Directory $output_directory already exist...!!!\n";		
	}
	else
	{
		if ( mkdir($output_directory,777))
		{
			print "$output_directory created successfully\n";
		}
		else
		{
			print "Error while creation $!\n";
		}
	}
	$output_directory =~ s/\\+/\\\\/g;
	return $output_directory;
} # End of Initial_Output_Configuration()
sub Initial_Input_Configuration
{
	my($Input_directory,$tool_scriptfile) = @_;
	if ( -d "$Input_directory")
	{
		#print "Directory $Input_directory already exist...!!!\n";
		$script_filename = $Input_directory . "\\" . $tool_scriptfile;
		if (-f "$script_filename")
		{
		#	print "$tool_scriptfile exist under $Input_directory folder\n";
		}
		else
		{
			print "Place the $tool_scriptfile file under $Input_directory\n";
			exit 0;
		}
	}
	else
	{
		if ( mkdir($Input_directory,777))
		{
			print "$Input_directory created successfully\n";
			print "Place the $tool_scriptfile file under $Input_directory\n";
			exit 0;
		}
		else
		{
			print "Error while creation $!\n";
		}
	}
	$script_filename =~ s/\\+/\\\\/g;
	return $script_filename;
} # End of Initial_Input_Configuration()
sub checkInputDir
{
	my($pmd_input_directory) = @_;
	if ( -f "$pmd_input_directory")
	{
		print " $pmd_input_directory is a file\n";
		print "Expected ===> Input Directory where source files are placed\n";
		exit 0;
	}
	elsif ( "$pmd_input_directory" =~ m/^\./)
	{
		print "$pmd_input_directory is a hidden folder/file \n";
		print "Expected ===> Input Directory where source files are placed\n";
		exit 0;
	}
	elsif ( -d "$pmd_input_directory")
	{
	#	print "$pmd_input_directory exist...!!!\n";
	}
	else
	{
		print "\n $pmd_input_directory doesn't exist in current directory.\n Please provide complete absolute path\n";
		exit 0;
	}
} # End of Initial_PMD_Input_Configuration()
sub Print_Values
{
	my ($Variable_name,$Variable_value) = @_;
	print "\nThe value of $Variable_name  is : $Variable_value\n"
} # End of Print_Values()
sub usage
{
	my ($Error_code) = @_;
	if ($Error_code == 255 )
	{
		print "\nUsage :- ";
		print "PMDSolutionTool.pl \"arg1\" \"arg2\"\n";
		print "\narg1:-  CheckStyle error HTML File generated by PMD Tool\n";
		print "        e.g \"C:\\PMDTool\\pmdreport\\checkstyle_report.html\"\n\n";
		print "arg2:-  Input Directory where source files (.java) over which Checkstyle Solution Tool is to be run are placed\n";
		exit
	}
} # End of usage()
sub Create_HashMap
{
	my ($ConfigFile_Name,$MatchFilename) = @_;
	%Line_Hashes = ();
	if ( -f "$ConfigFile_Name")
	{
		printf "Creating HashMap with Line number as Keys and Changes as Values\n";
		open(File_Hndlr,"$ConfigFile_Name");
		#print "The config file name is : $ConfigFile_Name\n";
		#print "The MatchFilename is : $MatchFilename\n";
		while(my $content = <File_Hndlr>)
		{	
			#print "Content is : $content\n";
			if ($content =~ m/$MatchFilename/ || $Config_file_Iterator == 1)
			{
				#print "Inside file match\n";
				if ($content =~ m/$File_Boundary/ && $Config_file_Iterator == 1)
				{
					$Config_file_Iterator = 0;
				}
				elsif ($content =~ m/^[0-9]/)
				{
						@splitValues=split(',', $content);
						$intLength_Array=$#splitValues+1;
						$Line_Hashes{$splitValues[0]} = $splitValues[1];
						#Print_Values(splitValues,$intLength_Array);
				}
				else
				{
					$Config_file_Iterator = 1;
				}
			}
		}
		close(File_Hndlr);
		while (($key, $value) = each %Line_Hashes)
		{
			print "$key has the changes mapped to $Line_Hashes{$key}\n";
		}
		printf "HashMap created\n";	
	}
	else
	{
		print "$ConfigFile_Name not created because there's some error with the HTML file parameter given to the Tool while running\n";
		print "Please provide correct HTML file\n";
		exit ;
	}
}	# End of Create_HashMap()
sub Processing_Directory()
{
	my($dirname) = @_;
	print "Processing Files for PMD Checkstyle correction under Folder $dirname\n";
	$Filename = "";
	$countJavaFiles = 0;
	opendir(DIR, $dirname) or die "No such file or directory";
	while (my $file = readdir(DIR))
	{	
		if ($file !~ m/^\./)
		{
			if (-f "$dirname\\$file") 					# Check for files
			{
				if ($file =~ m/\.java$/)				# Regular expression to find files ending in .java
				{
					$Filename = "$dirname\\$file";
					Processing_FileList("$Filename");	# Call Processing FileName
					$countJavaFiles = 1;
				}		
			}
		}	
	}
	if ($countJavaFiles == 0)
	{
		print "There were no java files to processed. Place the .java file inside folder $dirname and re-run the Tool\n";
		exit ;
	}
	else
	{
		print "Processing of .java files for PMD Checkstyle correction under Folder $dirname is done..!!!\n";
	}
	closedir(DIR);
} # End of Processing_Directory()
sub Processing_FileList
{
	my ($FileName) = @_;
	$Java_File_Name = (split(/\\/, "$FileName"))[-1];
	Create_HashMap($ConfigFileName,$Java_File_Name);
	Processing_FileName($FileName,$Java_File_Name);
	print "\nProcessing of $Java_File_Name completed...!!!\n";
	close(File_List);
}	# End of Processing_FileList()
sub Processing_FileName
{
	my ($File_Name,$Modified_Filename) = @_;
	printf "Processing $File_Name\n";
	$Lines = 0;
	$Space_Count = 0;
	
	# Name the output file name to write the output
	$outfile = $Output_File_Dir . "\\" . $Modified_Filename;
	#Print_Values(outfile,$outfile);
	chomp($outfile);
	# Remove the existing output filename if already exist
	Remove_Output_Already_Existed_File($outfile);
	# Open the output file name for processing
	open(File_Hndlr,"$File_Name");
	while(my $content = <File_Hndlr>)
	{		
		chomp($content);
		$length_content = length($content);
		$Lines = $Lines + 1;
		if ($Line_Hashes{$Lines})
		{
			#Print_Values(Line_Hashes_Lines_,$Line_Hashes{$Lines});
			if($Line_Hashes{$Lines} =~ /^(10)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = ",";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",10);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(20)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$content = Removing_Trailing_Space("$content");
				$content = Checking_other_Changes("$content",20);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(10)+[0-9]+$/ || $Line_Hashes{$Lines} =~ /^(20)+[0-9]+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = ",";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Removing_Trailing_Space("$content");
				$content = Checking_other_Changes("$content",10);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(40)+$/ || $Line_Hashes{$Lines} =~ /^(30)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$content = Adding_Space_After_Before_Plus("$content");
				$content = Checking_other_Changes("$content",40);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(40)+[0-9]+$/ || $Line_Hashes{$Lines} =~ /^(30)+[0-9]+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$content = Adding_Space_After_Before_Plus("$content");
				$content = Checking_other_Changes("$content",40);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(50)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "if";
				$content = Adding_Space_After_Keyword("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",50);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(60)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "=";
				$content = Adding_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",60);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(70)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "=";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",70);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(60)+[0-9]+$/ || $Line_Hashes{$Lines} =~ /^(70)+[0-9]+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "=";
				$content = Adding_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",70);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(80)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "{";
				$content = Adding_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",80);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(90)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$content = Adding_Dot_At_End("$content");
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(100)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = " ";
				$content = Change_static_order("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",100);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(110)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "!=";
				$content = Adding_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",110);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(120)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "!=";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",120);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(110)+[0-9]+$/ || $Line_Hashes{$Lines} =~ /^(120)+[0-9]+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "!=";
				$content = Adding_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",120);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(130)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "(";
				$content = Remove_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",130);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(140)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = ")";
				$content = Remove_Space_Before_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",140);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(130)+[0-9]+$/ || $Line_Hashes{$Lines} =~ /^(140)+[0-9]+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = ")";
				$content = Remove_Space_Before_Delimiter("$content",$delimiter_comma);
				$delimiter_comma = "(";
				$content = Remove_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",140);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(150)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "}";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",150);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(160)+[0-9]*$/ || $Line_Hashes{$Lines} =~ /^(20)+(160)+$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$content = AddComment("$content");
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(170)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "for";
				$content = Adding_Space_After_Keyword("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",170);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			elsif($Line_Hashes{$Lines} =~ /^(180)+[0-9]*$/)
			{
				#Print_Values(Content_inside_hashloop,$content);
				print "\nProcessing of Line $Lines for its related changes";
				$delimiter_comma = "{";
				$content = Adding_Space_After_Delimiter("$content",$delimiter_comma);
				$content = Checking_other_Changes("$content",180);
				#Print_Values(Content,$content);
				$length_content = length($content);
				write_to_file($outfile,$content,$length_content);
				print "\nProcessing of Line $Lines done..!!\n";
			}
			else
			{
				write_to_file($outfile,$content,$length_content);
			}
		}
		else
		{
			write_to_file($outfile,$content,$length_content);
		}
	}
	close(File_Hndlr);
}	# End of Processing_FileName()
sub write_to_file
{
	my($output_file_name,$data,$length) = @_;
	open(my $outfh, '>>', $output_file_name) or die "Could not open file '$output_file_name' $!";
	#if($length != 0)
	#{
		print $outfh "$data\n";
	#}	
	close $outfh;	
} # End of write_to_file()
sub Remove_Output_Already_Existed_File							# Delete the Output File if already exist
{
	$OutputFileName = "";
	my($OutputFileName) = @_;
	if (-e $OutputFileName)
	{
			if (unlink($OutputFileName) == 0)
			{
				print "File was not deleted.\n";
			} else {
				print "File deleted successfully.\n";
			}
	}
	else
	{
		print "File not exist\n";
	}	
} # End of Remove_Output_Already_Existed_File()
sub Adding_Dot_At_End											# Adding dot at end of line
{
	my($strdata) = @_;
	$strdata =~ s/^(.+)$/$1./g;
	$content = $strdata;
	#Print_Values(content,$content);
	return $content;
} # End of Adding_Dot_At_End()
sub AddComment													# Add comment to unused imports
{
	my($strdata) = @_;
	if ($strdata =~ m/^import/)									# Checks it starts with import
	{
		$strdata =~ s/^(.+)$/\/\/$1/g;
		$strdata =~ s/\s+$//g;
		$content = $strdata;
		#print "The value of addComment is :$content\n";
		return $content;
	}
	else
	{
		return $strdata;
	}
} # End of addComment()
sub Change_static_order											# static modifier out of JLS Suggestion
{
	my($strdata,$delimiter) = @_;
	@SplitStaticValues = split($delimiter,$strdata);
	#print "Original String is $strdata\n";
	$length_SplitStaticValues = $#SplitStaticValues + 1;
	for ($i = 0;$i < $length_SplitStaticValues;$i++)
	{
		$current_index = $i;
		$prev_index = $current_index - 1;
		$next_index = $current_index + 1;
		if("$SplitStaticValues[$current_index]" eq "static" && "$SplitStaticValues[$prev_index]" eq "final")
		{
			$tmp_holder = $SplitStaticValues[$current_index];
			$SplitStaticValues[$current_index] = $SplitStaticValues[$prev_index];
			$SplitStaticValues[$prev_index] = $tmp_holder;
		}
	}
	$strfinaldata = join " ", @SplitStaticValues;
	#print "static JLS suggestion :- $strfinaldata\n";
	return $strfinaldata;
} # End of Change_static_order()
sub Removing_Trailing_Space										#Removing Trailing Spaces
{
	my ($strData_to_remove_space) = @_;
	$strData_to_remove_space =~ s/\s+$//;
	return $strData_to_remove_space;
} # End of Removing_Trailing_Space()
sub Checking_other_Changes										# Checking for other changes
{
	$strfinaldata = "";
	$delimiter_checking = "";
	my($strdata,$change_id) = @_;
	$strfinaldata = $strdata;
	if ($strdata =~ m/,/ && $change_id != 10)
	{
		$delimiter_checking = ",";
		$strfinaldata = Adding_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/ +$/ && $change_id != 20)
	{
		$strfinaldata = Removing_Trailing_Space("$strfinaldata");
	}
	if ($strdata =~ m/\+/ && $change_id != 40 && $change_id != 30)
	{
		$strfinaldata = Adding_Space_After_Before_Plus("$strfinaldata");
	}
	if ($strdata =~ m/if/ && $change_id != 50)
	{
		$delimiter_checking = "if";
		$strfinaldata = Adding_Space_After_Keyword("$strfinaldata",$delimiter_checking);
	}
	if (($strdata =~ m/[aA-zZ]+[.\(\)]*[0-9]*\s*=/ || $strdata =~ m/[0-9]+[.\(\)]*[aA-zZ]*\s*=/) && $change_id != 70 && $change_id != 60 && $strdata !~ m/==/)
	{
		$delimiter_checking = "=";
		$strfinaldata = Adding_Space_Before_Delimiter("$strfinaldata",$delimiter_checking);
		$strfinaldata = Adding_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/{/ && $change_id != 80)
	{
		$delimiter_checking = "{";
		$strfinaldata = Adding_Space_Before_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/static/ && $change_id != 100)
	{
		$delimiter_checking = " ";
		$strfinaldata = Change_static_order("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/!=/ && $change_id != 120 && $change_id != 110)
	{
		$delimiter_checking = "!=";
		$strfinaldata = Adding_Space_Before_Delimiter("$strfinaldata",$delimiter_checking);
		$strfinaldata = Adding_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if (($strdata =~ m/\(/ || $strdata =~ m/\)/) && $change_id != 130 && $change_id != 140)
	{
		$delimiter_checking = ")";
		$strfinaldata = Remove_Space_Before_Delimiter("$strfinaldata",$delimiter_checking);
		$delimiter_checking = "(";
		$strfinaldata = Remove_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/}/ && $change_id != 150)
	{
		$delimiter_checking = "}";
		$strfinaldata = Adding_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/^import/ && $change_id != 160)
	{
		$strfinaldata = AddComment("$strfinaldata");
	}
	if ($strdata =~ m/for/ && $change_id != 170)
	{
		$delimiter_checking = "for";
		$strfinaldata = Adding_Space_After_Keyword("$strfinaldata",$delimiter_checking);
	}
	if ($strdata =~ m/{/ && $change_id != 180)
	{
		$delimiter_checking = "{";
		$strfinaldata = Adding_Space_After_Delimiter("$strfinaldata",$delimiter_checking);
	}
	return $strfinaldata;
} # End of Checking_other_Changes()
sub Remove_Space_Before_Delimiter									# Removing Space Before Delimiter
{
	my($strdata,$delimiter) = @_;
	@Split_Values_Space = split(undef,"$strdata");
	$length_space = $#Split_Values_Space + 1;
	for($i = 0;$i<$length_space;$i++)
	{
		$count_space = 0;
		if($Split_Values_Space[$i] eq $delimiter)
		{
			$count_space = $i - 1;
			while($Split_Values_Space[$count_space] =~ m/\s+/)
			{
				delete($Split_Values_Space[$count_space]);
				$count_space = $count_space - 1;
			}
		}
	}
	#Merging the data
	$length_space = $#Split_Values_Space + 1;
	$strFinalData = "";
	for($j = 0;$j<$length_space;$j++)
	{
		$strFinalData = $strFinalData . $Split_Values_Space[$j];
	}
	#print "\nThe value of strFinalData is $strFinalData\n";
	return $strFinalData;
} # End of Remove_Space_Before_Delimiter()
sub Remove_Space_After_Delimiter									# Removing Space After Delimiter
{
	my($strdata,$delimiter) = @_;
	@Split_Values_Space = split(undef,"$strdata");
	$length_space = $#Split_Values_Space + 1;
	for($i = 0;$i<$length_space;$i++)
	{
		$count_space = 0;
		if($Split_Values_Space[$i] eq $delimiter)
		{
			$count_space = $i + 1;
			while($Split_Values_Space[$count_space] =~ m/\s+/)
			{
				delete($Split_Values_Space[$count_space]);
				$count_space = $count_space + 1;
			}
		}
	}
	#Merging the data
	$length_space = $#Split_Values_Space + 1;
	$strFinalData = "";
	for($j = 0;$j<$length_space;$j++)
	{
		$strFinalData = $strFinalData . $Split_Values_Space[$j];
	}
	#print "\nThe value of strFinalData is $strFinalData\n";
	return $strFinalData;
} # End of Remove_Space_After_Delimiter()
sub Adding_Space_After_Before_Plus									# Adding space after and before to delimiter
{
	my($strdata1) = @_;
	@SplitUndefValues = split(undef,$strdata1);
	$length_UndefValues = $#SplitUndefValues + 1;
	$Prev_Index = 0;
	$Next_Index = 0;
	$Current_Index = 0;
	$strFinalData = "";
	$space = " ";
	for ($i = 0;$i < $length_UndefValues;$i++)
	{
		if ("$SplitUndefValues[$i]" ne "+")
		{
			$strFinalData = $strFinalData . $SplitUndefValues[$i];
		}
		else
		{
			$Current_Index = $i;
			$Prev_Index = $Current_Index - 1;
			$Next_Index = $Current_Index + 1;
			if (("$SplitUndefValues[$Prev_Index]" eq $space && "$SplitUndefValues[$Current_Index]" eq "+" )|| $Prev_Index < 0)
			{
				$strFinalData = $strFinalData . $SplitUndefValues[$Current_Index];
			}
			elsif("$SplitUndefValues[$Next_Index]" ne "+" && $Next_Index < $length_UndefValues && "$SplitUndefValues[$Prev_Index]" ne "+")
			{
				$strFinalData = $strFinalData . " " . $SplitUndefValues[$Current_Index];
			}
			else
			{
				$strFinalData = $strFinalData . $SplitUndefValues[$Current_Index];
			}
			if ("$SplitUndefValues[$Next_Index]" ne $space && $Next_Index < $length_UndefValues && "$SplitUndefValues[$Next_Index]" ne "+"
			&& "$SplitUndefValues[$Prev_Index]" ne "+")
			{
				$strFinalData = $strFinalData . " ";
			}
			
		}
	}
	#Print_Values(strFinalData,$strFinalData);
	return $strFinalData;
} # End of Adding_Space_After_Before_Plus()
sub Adding_Space_After_Keyword										# Adding Space after Keyword like if,for,while etc
{
	my($strdata,$delimiter) = @_;
	@Split_Values_by_Keyword = split(/(\()/,$strdata);
	$length_keyword = $#Split_Values_by_Keyword + 1;
	$strFinalData = "";
	$next_indx = 0;
	for ($k = 0;$k<$length_keyword;$k++)
	{
		#print "\nSplit_Values_by_Keyword[$k]===> $Split_Values_by_Keyword[$k]\n";
		$next_indx = $k + 1;
		if ($Split_Values_by_Keyword[$k] =~ m/^\s*(})*\s*(else)*\s*($delimiter)$/ && $Split_Values_by_Keyword[$next_indx] =~ m/\(/)
		{
			#print "\nSplit_Values_by_Keyword[$k]===> $Split_Values_by_Keyword[$k]\n";
			$strFinalData = $strFinalData . $Split_Values_by_Keyword[$k] . " ";
		}
		else
		{
			$strFinalData = $strFinalData . $Split_Values_by_Keyword[$k];
		}
	}
	#print "The value of strFinalData is $strFinalData\n";
	return $strFinalData;
} # End of Adding_Space_After_Keyword()
sub Adding_Space_After_Delimiter									# Adding_Space_After_Delimiter
{
	# Resetting all values
	$strFinalString = "";
	@PrepareString = ();
	@splitValues = ();
	
	my($strData,$Delimiter) = @_;
	if ($strData =~ m/$Delimiter/)
	{
		@splitValues=split($Delimiter, $strData);
	}
	$intLength_splitValues=$#splitValues+1;
	$intNumber_Of_Space=$intLength_splitValues-1;
	$intSplitIterator = 0;
	
	for($i = 0;$i < ($intLength_splitValues + $intNumber_Of_Space),$intSplitIterator < $intLength_splitValues;$i++)
	{
		if(($i % 2) == 0)
		{
			if($intLength_splitValues == 1)
			{
				$PrepareString[$i] = $splitValues[$intSplitIterator] . $Delimiter;
				$intSplitIterator = $intSplitIterator + 1;
			}
			else
			{
				$PrepareString[$i] = $splitValues[$intSplitIterator];
				$intSplitIterator = $intSplitIterator + 1;
			}			
		}
		else
		{
			if($splitValues[$intSplitIterator] !~ /^ +/)
			{
				$PrepareString[$i] = $Delimiter . " ";
			}
			else
			{
				$PrepareString[$i] = $Delimiter;
			}
		}
	}
	if ($strData =~ m/$Delimiter$/ && $intLength_splitValues != 1)
	{	
		$PrepareString[$i] = $Delimiter;
	}
	$intLength_PrepareString=$#PrepareString+1;
	if ($intLength_PrepareString != 0)
	{
		for($j = 0;$j < $intLength_PrepareString;$j++)
		{
			$strFinalString = "$strFinalString" . $PrepareString[$j];
		}
		# Return Final Formatted String
		return $strFinalString;	
	}
	else
	{
		return $strData;
	}
}	#End of Adding_Space_After_Delimiter()
sub Adding_Space_Before_Delimiter								# Adding space before delimiter
{
	# Resetting all values
	$strFinalString = "";
	@PrepareString = ();
	@splitValues = ();
	
	my($strData,$Delimiter) = @_;
	if ($strData =~ m/$Delimiter/)
	{
		@splitValues=split($Delimiter, $strData);
	}
	$intLength_splitValues=$#splitValues+1;
	$intNumber_Of_Space=$intLength_splitValues-1;
	$intSplitIterator = 0;
	
	for($i = 0;$i < ($intLength_splitValues + $intNumber_Of_Space),$intSplitIterator < $intLength_splitValues;$i++)
	{
		if(($i % 2) == 0)
		{
			if($intLength_splitValues == 1)
			{
				if ($splitValues[$intSplitIterator] !~ / +$/)
				{
					$PrepareString[$i] = $splitValues[$intSplitIterator] . " " . $Delimiter;
					$intSplitIterator = $intSplitIterator + 1;
				}
				else
				{
					$PrepareString[$i] = $splitValues[$intSplitIterator] . $Delimiter;
					$intSplitIterator = $intSplitIterator + 1;
				}
			}
			else
			{
				$PrepareString[$i] = $splitValues[$intSplitIterator];
				$intSplitIterator = $intSplitIterator + 1;
			}			
		}
		else
		{
			if($splitValues[$intSplitIterator - 1] !~ / +$/)
			{
				$PrepareString[$i] = " " . $Delimiter;
			}
			else
			{
				$PrepareString[$i] = $Delimiter;
			}
		}
	}
	$intLength_PrepareString=$#PrepareString+1;
	if ($intLength_PrepareString != 0)
	{
		for($j = 0;$j < $intLength_PrepareString;$j++)
		{
			$strFinalString = "$strFinalString" . $PrepareString[$j];
		}		
		# Return Final Formatted String
		return $strFinalString;	
	}
	else
	{
		return $strData;
	}
}	#End of Adding_Space_Before_Delimiter()