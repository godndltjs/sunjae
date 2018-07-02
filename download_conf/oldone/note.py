
# from subprocess import Popen, PIPE
# from os import path
# import subprocess
import git


# git_command = ['/usr/bin/git', 'status']
# repository  = path.dirname('/path/to/dir/') 

# git_query = Popen(git_command, cwd=repository, stdout=PIPE, stderr=PIPE)
# (git_status, error) = git_query.communicate()
# if git_query.poll() == 0:


# git_command = ['git', 'log', '--since="2days ago" --pretty=format:"%s : %b"']
# repository  = path.dirname('C:/Users/VT/Desktop/CM/02. 정기 릴리즈/MakeReleaseNote/meta-mango/') 
# # Simple command
# # subprocess.call(git_command, cwd=repository, shell=True)
# git_query = Popen(git_command, cwd=repository, stdout=PIPE, stderr=PIPE)



day="6"
g = git.Git("C:/Users/VT/Desktop/CM/02. 정기 릴리즈/MakeReleaseNote/meta-mango/") 
loginfo = g.log("--since=" + day + "days ago",'--pretty=format:%s : %b')
# loginfo = g.status()
loginfo = loginfo.readline()
print (loginfo)


# my_file = open('C:/Users/VT/Desktop/CM/SCRIPT/pro.txt')
# line = my_file.readlines()
# print(line)
# my_file.close()


# family=['a','b','c','d']
# family.append('e')
# print (len(family))