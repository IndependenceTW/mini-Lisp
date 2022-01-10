# mini-Lisp

## Environment
- WSL2.0 Ubuntu 20.04 LTS
- flex 2.6.4
- bison (GNU Bison) 3.5.1
- VSCode
    - Yash

## Feature
### Basic
- [x] Syntax Validation
- [x] Print
- [x] Numerical Operations
- [x] Logical Operators
- [x] if Expression
- [x] Variable Defination

---
Give up :(
- [ ] Function
- [ ] Named Function

### Bonus
- [ ] Recursion
- [ ] Type Checking
- [ ] Nested Function
- [ ] First-class Function


## Method
- Use tree
    - 就是把整個程式建成一棵樹之後再處理
    - 以 (+ 1 2)來說，我們會先把 '+' 當作一個root node，然後左右小孩分別是1和2，這樣就建好樹了
    - 然後就是把建好的樹用postorder的方式拜訪過一次，就完成了

- Use stack
    這是突發奇想的方法，複雜程度應該跟tree差不多

