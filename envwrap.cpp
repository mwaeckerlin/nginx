/**

Bring environment variables into stupid NGNIX to be able to configure at Docker instanciation time.

It combines envsubst with execution of another command, to be able to run in a headless, shell free Docker image.

Usage:

   envwrap <inpath> <outpath> <command> <args..>

inpath and outpath could also be a files not dirs

E.g.
  Substitute all availale environment variables from all files in /etc/nginx.template and store the updated files in /etc/nginx, then run "/usr/bin/nginx -t":

  envwrap /etc/nginx.template /etc/nginx /usr/bin/nginx -t

 */

#include <exception>
#include <filesystem>
#include <fstream>
#include <iostream>
#include <string>
#include <unistd.h>
#include <unordered_map>
#include <vector>

namespace fs = std::filesystem;

static std::string
substitute(const std::string &input,
           const std::unordered_map<std::string, std::string> &envs) {
  std::string out = input;
  for (const auto &kv : envs) {
    const std::string needle = "${" + kv.first + "}";
    std::size_t pos = 0;
    while ((pos = out.find(needle, pos)) != std::string::npos) {
      out.replace(pos, needle.size(), kv.second);
      pos += kv.second.size();
    }
  }
  return out;
}

static void
copy_with_subst(const fs::path &src_root, const fs::path &dst_root,
                const std::unordered_map<std::string, std::string> &envs) {
  if (!fs::exists(src_root))
    throw std::runtime_error("template root not found: " + src_root.string());

  const bool src_is_dir = fs::is_directory(src_root);
  const bool dst_exists = fs::exists(dst_root);
  if (src_is_dir) {
    if (dst_exists && !fs::is_directory(dst_root))
      throw std::runtime_error("destination must be directory: " + dst_root.string());
    if (!dst_exists) fs::create_directories(dst_root);
    else {
      for (const auto &entry : fs::directory_iterator(dst_root)) {
        fs::remove_all(entry.path());
      }
    }
    for (const auto &entry : fs::recursive_directory_iterator(src_root)) {
      const auto rel = fs::relative(entry.path(), src_root);
      const fs::path dst = dst_root / rel;
      if (entry.is_directory()) {
        fs::create_directories(dst);
        continue;
      }
      fs::create_directories(dst.parent_path());
      std::ifstream in(entry.path(), std::ios::binary);
      std::string content((std::istreambuf_iterator<char>(in)),
                          std::istreambuf_iterator<char>());
      auto substituted = substitute(content, envs);
      std::ofstream out(dst, std::ios::binary);
      out << substituted;
    }
  } else {
    if (dst_exists && fs::is_directory(dst_root))
      throw std::runtime_error("destination must be file: " + dst_root.string());
    if (dst_root.has_parent_path()) fs::create_directories(dst_root.parent_path());
    std::ifstream in(src_root, std::ios::binary);
    std::string content((std::istreambuf_iterator<char>(in)),
                        std::istreambuf_iterator<char>());
    auto substituted = substitute(content, envs);
    std::ofstream out(dst_root, std::ios::binary);
    out << substituted;
  }
}

int main(int argc, char *argv[]) try {
  std::unordered_map<std::string, std::string> envs;
  std::vector<std::string> args(argv + 1, argv + argc);
  std::vector<std::string> cmd;
  fs::path tmpl_root;
  fs::path dst_root;

  for (auto it = args.begin(); it != args.end(); ++it) {
    if (*it == "--from") {
      auto next = std::next(it);
      if (next == args.end())
        throw std::runtime_error("missing path after --from");
      tmpl_root = *next;
      it = next;
      continue;
    }
    if (*it == "--to") {
      auto next = std::next(it);
      if (next == args.end())
        throw std::runtime_error("missing path after --to");
      dst_root = *next;
      it = next;
      continue;
    }
    if (*it == "--substitute-env") {
      auto next = std::next(it);
      if (next == args.end())
        throw std::runtime_error("missing env name after --substitute-env");
      const std::string &name = *next;
      const char *val = std::getenv(name.c_str());
      envs[name] = val ? std::string(val) : std::string();
      it = next;
      continue;
    }
    cmd.emplace_back(*it);
  }
  if (cmd.empty())
    throw std::runtime_error("no command provided, add a command to execute after substitution");
  if (tmpl_root.empty())
    throw std::runtime_error("no input provided, add --in <infile>|<indir>");
  if (dst_root.empty())
    throw std::runtime_error("no output provided, add --out <outfile>|<outdir>");

  copy_with_subst(tmpl_root, dst_root, envs);

  std::vector<char *> exec_argv;
  exec_argv.reserve(cmd.size() + 1);
  for (auto &s : cmd) {
    exec_argv.push_back(const_cast<char *>(s.c_str()));
  }
  exec_argv.push_back(nullptr);
  execvp(exec_argv[0], exec_argv.data());
  std::cerr << "execvp failed for";
  for (auto *p : exec_argv) {
    if (!p) break;
    std::cerr << " [" << p << "]";
  }
  std::cerr << std::endl;
  std::perror("execvp");
  return 1;
} catch (const std::string &s) {
  std::cerr << "ERROR: " << s << std::endl;
  return 1;
} catch (const std::exception &e) {
  std::cerr << "EXCEPTION: " << e.what() << std::endl;
  return 1;
} catch (...) {
  std::cerr << "UNKNOWN ERROR" << std::endl;
  return 1;
}
