open CamomileLibrary
open Printf
open Fonts.FTypes
open OutputCommon
open Box
open Line
open Document
open Util
module Buf=UTF8.Buf


type page = { mutable pageFormat:float*float; mutable pageContents:raw list }

let defaultPage={pageFormat=(0.,0.);pageContents=[]}

module type Driver=sig
  val output: ?structure:structure -> page array -> string -> unit
end
