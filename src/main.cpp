#include <userver/clients/http/component.hpp>
#include <userver/components/minimal_server_component_list.hpp>
#include <userver/server/handlers/ping.hpp>
#include <userver/server/handlers/tests_control.hpp>
#include <userver/testsuite/testsuite_support.hpp>
#include <userver/utils/daemon_run.hpp>

#include "handler_api/handler_api.hpp"
//#include "handler_static/handler_static.h"

#include <userver/server/handlers/http_handler_static.hpp>

int main(int argc, char* argv[]) {
    auto component_list = userver::components::MinimalServerComponentList()
        .Append<userver::server::handlers::Ping>()
        .Append<userver::components::TestsuiteSupport>()
        .Append<userver::components::HttpClient>()
        .Append<userver::server::handlers::TestsControl>()
        .Append<userver::components::FsCache>("fs-cache-main")
        .Append<userver::server::handlers::HttpHandlerStatic>();

    u_tasks_repository::AppendHandlerApi(component_list);

    return userver::utils::DaemonMain(argc, argv, component_list);
}
