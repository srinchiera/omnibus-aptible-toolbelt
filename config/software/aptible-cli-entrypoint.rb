name 'aptible-cli-entrypoint'

build do
  def windows_escaped_path(*components)
    windows_safe_path(*components).gsub(File::ALT_SEPARATOR) do
      "#{File::ALT_SEPARATOR}#{File::ALT_SEPARATOR}"
    end
  end

  env = {
    'APPBUNDLER_ALLOW_RVM' => '',
    'BUNDLE_ORIG_PATH' => '',
    'BUNDLE_ORIG_GEM_PATH' => '',
    'BUNDLE_BIN_PATH' => '',
    'BUNDLE_GEMFILE' => '',
    'RUBY_ROOT' => '',
    'RUBYOPT' => '',
    'RUBY_ENGINE' => '',
    'RUBY_VERSION' => '',
    'RUBYLIB' => '',

    'APTIBLE_TOOLBELT' => '1'
  }

  if windows?
    bindir = windows_escaped_path(install_dir, 'embedded', 'bin')

    cert_components = [install_dir, 'embedded', 'ssl', 'certs']
    env['SSL_CERT_DIR'] = windows_escaped_path(*cert_components)
    env['SSL_CERT_FILE'] = windows_escaped_path(*cert_components, 'cacert.pem')

    build = "#{install_dir}/embedded/src"
    mkdir build

    erb(
      source: 'aptible.c.erb',
      dest: windows_safe_path(build, 'aptible.c'),
      vars: { env: env, bindir: bindir }
    )

    vcvarsall = windows_safe_path(
      'C:', 'Program Files (x86)', 'Microsoft Visual Studio', '2017',
      'Community', 'VC', 'Auxiliary', 'Build', 'vcvarsall.bat'
    )

    command %("#{vcvarsall}" x86_amd64 8.1 && cl /W2 /WX aptible.c),
            cwd: build

    exe = 'aptible.exe'
    move("#{build}/#{exe}", "#{install_dir}/bin/#{exe}")
  else
    cli_entrypoint = "#{install_dir}/bin/aptible"

    block do
      require 'shellwords'

      File.open(cli_entrypoint, 'w') do |f|
        f.puts('#!/bin/sh')

        env.each do |k, v|
          if v == ''
            f.puts(%(unset #{k}))
          else
            f.puts(%(export #{k}=#{Shellwords.escape(v)}))
          end
        end
        f.puts(%(export PATH="#{install_dir}/embedded/bin:$PATH"))

        f.puts(%(exec "#{install_dir}/embedded/bin/aptible" "$@"))
      end

      command "chmod 755 #{cli_entrypoint}"
    end
  end
end
