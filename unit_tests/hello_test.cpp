#include "../src/handler_api/handler_api.hpp"

#include <userver/utest/utest.hpp>

UTEST(SayHelloTo, Basic) {
    using u_tasks_repository::SayHelloTo;
    using u_tasks_repository::UserType;

    EXPECT_EQ(SayHelloTo("Developer", UserType::kFirstTime), "Hello, Developer!\n");
    EXPECT_EQ(SayHelloTo({}, UserType::kFirstTime), "Hello, unknown user!\n");

    EXPECT_EQ(SayHelloTo("Developer", UserType::kKnown), "Hi again, Developer!\n");
}
