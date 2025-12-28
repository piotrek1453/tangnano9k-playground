package projectname

import spinal.core._

import sys.process._

// Hardware definition
case class MyTopLevel() extends Component {
  val io = new Bundle {
    val clk_in = in Bool ()
    val reset_in = in Bool ()
    val led_out = out Bits (6 bits)
  }

  val cd = ClockDomain(
    clock = io.clk_in,
    reset = io.reset_in,
    config = ClockDomainConfig(
      resetKind = ASYNC,
      resetActiveLevel = HIGH
    )
  )

  val area = new ClockingArea(cd) {
    val counter = Reg(UInt(32 bits)) init 0
    val led = Reg(Bits(6 bits)) init (0)

    counter := counter + 1

    when(counter === 0) {
      led := ~led
    }

    io.led_out := led
  }
}

object MyTopLevelVerilog extends App {
  Config.spinal.generateVerilog(MyTopLevel())
}

object MyTopLevelVhdl extends App {
  Config.spinal.generateVhdl(MyTopLevel())
}
