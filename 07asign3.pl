#!/usr/bin/perl

# Author: Huy Le

# Perl3: a program to simulate addusr command 

my $pwd = `pwd`;
chomp($pwd);

# User Input

sub input_value($) {
my ( $text ) = @_;
my $val = "";
while ( $val eq "" ) {
print "$text : " if ( $defvalue eq "" );
$val = <STDIN>;
chomp($val);
}
return $val;
}

##Taking user inputs
my $name = input_value("\nEnter the user full name : ");
my $user_id;
while(1) {
$user_id= input_value( "\nEnter the unique user id : " );
last if ( ! `egrep "^$user_id" passwd`);
print "User '$user_id' already exists, Try Again\n";
}
my $phone = input_value("\nEnter the user's phone number : ");

## Finding uid and gid and incrementing it with 1
my $uid;
my $gid;
$uid= `tail -1 passwd | awk -F':' '{print \$3+1}'`;
$gid = `tail -1 passwd | awk -F':' '{print \$4+1}'`;
chomp($uid);
chomp($gid);

#Creating user's home dir and copying .bash_profile to it
system("mkdir -p $pwd/home/$user_id");
system("cp /etc/skel/.bash_profile $pwd/home/$user_id");

my $dir = "$pwd/home/$user_id";
my $shell = "/bin/bash";

##Writting data to passwd and group copy files
`sed -i "\$ a $user_id:x:$uid:$gid:$name,$phone:$dir:$shell" passwd`;
`sed -i "\$ a $user_id:x:$gid:" group`;
