# example class
class Person:
    "This is a person class"
    age = 10
    
    # init function is called when creating new object
    def __init__(self, name):
        self.name = name
        
    def greet(self):
        return('Hello, ' + self.name)