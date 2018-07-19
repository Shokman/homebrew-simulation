class IgnitionSensors0 < Formula
  desc "Sensors library for robotics applications"
  homepage "https://bitbucket.org/ignitionrobotics/ign-sensors"
  url "https://bitbucket.org/ignitionrobotics/ign-sensors/get/a44a773b2ce9.tar.gz"
  version "0.0.0~20180718~a44a773"
  sha256 "9406cc1577a7024e5b6fd1b3c5fe1fa6d4e8c20e10045c3fdb64eda6a884a688"

  head "https://bitbucket.org/ignitionrobotics/ign-sensors", :branch => "default", :using => :hg

  depends_on "cmake" => :build

  depends_on "ignition-common3"
  depends_on "ignition-math6"
  depends_on "ignition-msgs3"
  depends_on "ignition-rendering1"
  depends_on "ignition-transport6"
  depends_on "pkg-config"
  depends_on "sdformat6"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.cpp").write <<-EOS
      #include <iostream>

      #include <ignition/rendering.hh>
      #include <ignition/sensors.hh>

      int main()
      {
        // Setup ign-rendering with a scene
        auto *engine = ignition::rendering::engine("ogre");
        if (!engine)
        {
          std::cerr << "Failed to load ogre\n";
          return 1;
        }
        ignition::rendering::ScenePtr scene = engine->CreateScene("scene");

        // Add stuff to take a picture of
        BuildScene(scene);

        // Create a sensor manager
        ignition::sensors::Manager mgr;
        mgr.SetRenderingScene(scene);

        return 0;
      }
    EOS
    ENV.append_path "PKG_CONFIG_PATH", "#{Formula["qt"].opt_lib}/pkgconfig"
    system "pkg-config", "ignition-sensors"
    cflags   = `pkg-config --cflags ignition-sensors`.split(" ")
    ldflags  = `pkg-config --libs ignition-sensors`.split(" ")
    system ENV.cc, "test.cpp",
                   *cflags,
                   *ldflags,
                   "-lc++",
                   "-o", "test"
    system "./test"
  end
end
