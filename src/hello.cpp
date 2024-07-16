#include "hello.hpp"

#include <fmt/format.h>

#include <userver/clients/dns/component.hpp>

#include <userver/components/component.hpp>

#include <userver/server/handlers/http_handler_base.hpp>

#include <userver/storages/postgres/cluster.hpp>
#include <userver/storages/postgres/component.hpp>
#include <userver/storages/postgres/options.hpp>
#include <userver/storages/postgres/dsn.hpp>
#include <userver/storages/postgres/cluster_types.hpp>

#include <userver/utils/assert.hpp>

namespace u_tasks_repository {

namespace {

class Hello final : public userver::server::handlers::HttpHandlerBase {

public:
  static constexpr std::string_view kName = "handler-hello";

  Hello(
    const userver::components::ComponentConfig& config,
    const userver::components::ComponentContext& component_context)
    : HttpHandlerBase(config, component_context)
    , pg_cluster_(
      component_context
      .FindComponent<userver::components::Postgres>("postgres-db-1")
      .GetCluster())
  {
    constexpr auto kCreateShema =
      R"~(
        CREATE SCHEMA IF NOT EXISTS hello_schema;
      )~";

    constexpr auto kCreateTable =
      R"~(
        CREATE TABLE IF NOT EXISTS hello_schema.users (
          name VARCHAR PRIMARY KEY,
          count INT NOT NULL
        )
      )~";

    using userver::storages::postgres::ClusterHostType;
    pg_cluster_->Execute(ClusterHostType::kMaster, kCreateShema);
    pg_cluster_->Execute(ClusterHostType::kMaster, kCreateTable);

  }

  std::string HandleRequestThrow(
      const userver::server::http::HttpRequest& request,
      userver::server::request::RequestContext&) const override
  {
    const auto& name = request.GetArg("name");

    auto user_type = UserType::kFirstTime;
    if (!name.empty()) {
      auto result = pg_cluster_->Execute(
          userver::storages::postgres::ClusterHostType::kMaster,
          "INSERT INTO hello_schema.users(name, count) VALUES($1, 1) "
          "ON CONFLICT (name) "
          "DO UPDATE SET count = users.count + 1 "
          "RETURNING users.count",
          name);

      if (result.AsSingleRow<int>() > 1) {
        user_type = UserType::kKnown;
      }
    }

    return u_tasks_repository::SayHelloTo(name, user_type);
  }

  userver::storages::postgres::ClusterPtr pg_cluster_;
};

}  // namespace

std::string SayHelloTo(std::string_view name, UserType type) {
  if (name.empty()) {
    name = "unknown user";
  }

  switch (type) {
    case UserType::kFirstTime:
      return fmt::format("Hello, {}!\n", name);
    case UserType::kKnown:
      return fmt::format("Hi again, {}!\n", name);
  }

  UASSERT(false);
}

void AppendHello(userver::components::ComponentList& component_list) {
  component_list.Append<Hello>();
  component_list.Append<userver::components::Postgres>("postgres-db-1");
  component_list.Append<userver::clients::dns::Component>();
}

}  // namespace u_tasks_repository
