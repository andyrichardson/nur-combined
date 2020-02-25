import ./default-boilerplate.nix {
  modules = { #{{{1
    attrsets = import ./attrsets.nix;
    # edn = import ./edn;
    fixedPoints = import ./fixed-points.nix;
    licenses = import ./licenses.nix;
    lists = import ./lists.nix;
    meta = import ./meta.nix;
    trivial = import ./trivial.nix;
    # utf8 = import ./utf-8;
  };
  reexports = { lib, libSuper }: { #{{{1
    inherit (lib.attrsets) #{{{2
      mapAttr
      mapAttr'
      mapAttrOr mapAttrOrElse
      mapOptionalAttr
    ;

    inherit (lib.fixedPoints) #{{{2
      composeExtensionList
    ;

    inherit (lib.lists) #{{{2
      foldl1'
    ;

    inherit (lib.meta) #{{{2
      addMetaAttrs'
      setDrvBroken breakDrv unbreakDrv
    ;

    inherit (lib.trivial) #{{{2
      apply applyOp
      comp compOp flow
      comp2 comp2Op flow2
      comp3 comp3Op flow3
      hideFunctionArgs
      mapFunctionArgs
      mapIf
    ;
    #}}}2
  };
  #}}}1
}
# vim:fdm=marker:fdl=1
