read -p "enter the test case number: " case_number
./lisp <./in/${case_number}.in >./out/${case_number}.out
cat ./out/${case_number}.out