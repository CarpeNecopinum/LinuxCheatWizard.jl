// build: g++ victim.cc -o victim

#include <iostream>

volatile int gold = 0;

int main() {
    for (;;) {
        std::string line;
        std::getline(std::cin, line);

        try {
            gold = std::stoi(line);
        } catch (std::invalid_argument) {}

        std::cout << gold << std::endl;
    }
}