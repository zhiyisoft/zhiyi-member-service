# -*- coding: utf-8 -*-
require 'ldap'

module Zhiyi
  module Member
    def self.load file
      Ldap.load_config YAML::load(File.open(file))
    end

    class Ldap
      @@config = nil
      @@connect = nil

      def self.load_config configure
        @@config = configure
      end

      def self.config
        raise "Please load config file before use me!" if @@config.nil?
        @@config
      end

      def self.connect
        if @@connect.nil? then
          conn = LDAP::Conn.new(config['host'], config['port'])
          conn.set_option(LDAP::LDAP_OPT_PROTOCOL_VERSION, 3)
          conn.bind(config['bind']['dn'], config['bind']['passwd'])
          conn.perror("bind")
          @@connect = conn
        end
        @@connect
      end
    end



    class User
      # --------------------------------------------------------------------------------
      # 用户是否存在
      # --------------------------------------------------------------------------------
      def self.exist? uid
        not search("(uid=#{uid})").empty?
      end

      # --------------------------------------------------------------------------------
      # 列出全部用户
      # --------------------------------------------------------------------------------
      def self.all
        search('(objectclass=person)')
      end

      # --------------------------------------------------------------------------------
      # 增加一个用户
      # --------------------------------------------------------------------------------
      def self.add person
        p '------------------------------------------------------------', Zhiyi::Member::Ldap.config
        entry = [LDAP.mod(LDAP::LDAP_MOD_ADD,'objectclass', Zhiyi::Member::Ldap.config['objectclass'])] +
          (Zhiyi::Member::Ldap.config['attr'].map {|x| LDAP.mod(LDAP::LDAP_MOD_ADD, x, [person[x.to_sym]])})

        begin
          p '------------------------------------------------------------', 1
          Zhiyi::Member::Ldap.connect.add("uid=#{person[:uid]},#{Zhiyi::Member::Ldap.config['base']['person']}", entry)
          p '------------------------------------------------------------', 2
        rescue LDAP::ResultError
          raise "No, No"
        end
      end

      # --------------------------------------------------------------------------------
      # 检查我的口令是否正确
      # --------------------------------------------------------------------------------
      def self.mypass? uid, mypass
        not search("(&(uid=#{uid})(userPassword=#{mypass}))").empty?
      end

      # --------------------------------------------------------------------------------
      # 重置口令
      # --------------------------------------------------------------------------------
      def self.reset_password uid, newpass
        entry = [ LDAP.mod(LDAP::LDAP_MOD_REPLACE, 'userPassword', [newpass]) ]

        begin
          Zhiyi::Member::Ldap.connect.modify("uid=#{uid}, #{Zhiyi::Member::Ldap.config['base']['person']}", entry)
        rescue LDAP::ResultError
          raise
        end
      end

      # --------------------------------------------------------------------------------
      # 修改信息
      # --------------------------------------------------------------------------------
      def self.update_info uid,arges
        update_infos = []
        arges.each do |k,v|
          update_infos << LDAP.mod(LDAP::LDAP_MOD_REPLACE, k.to_s, [v.to_s])
        end
        begin
          Zhiyi::Member::Ldap.connect.modify("uid=#{uid}, #{Zhiyi::Member::Ldap.config['base']['person']}", update_infos)
        rescue LDAP::ResultError
          raise
        end
      end

      # --------------------------------------------------------------------------------
      # 删除用户
      # --------------------------------------------------------------------------------
      def self.delete uid
        begin
          Zhiyi::Member::Ldap.connect.delete("uid=#{uid}, #{Zhiyi::Member::Ldap.config['base']['person']}")
        rescue LDAP::ResultError
          raise
        end
      end

      # --------------------------------------------------------------------------------
      # 查询用户
      # --------------------------------------------------------------------------------
      def self.get_by_uid uid
        search("(&(uid=#{uid}))").first
      end


      # ================================================================================
      # 以下为私有方法
      # ================================================================================
      private

      # --------------------------------------------------------------------------------
      # 查找功能
      # --------------------------------------------------------------------------------
      def self.search filter
        result = []
        Zhiyi::Member::Ldap.connect.search(Zhiyi::Member::Ldap.config['base']['person'], 
                                           LDAP::LDAP_SCOPE_SUBTREE,
                                           filter,
                                           Zhiyi::Member::Ldap.config['attr'] + ['dn']) do |entry|
          result << ({
                       dn: entry.dn.force_encoding('UTF-8'),
                       display: entry.vals('displayName').nil? ? "" : entry.vals('displayName')[0].force_encoding('UTF-8'),
                       sn: entry.vals('sn').nil? ? "" : entry.vals('sn')[0].force_encoding('UTF-8'),
                       cn:  entry.vals('cn').nil? ? "" : entry.vals('cn')[0].force_encoding('UTF-8'),
                       mail: entry.vals('mail').nil? ? "" : entry.vals('mail')[0].force_encoding('UTF-8'),
                       mobile: entry.vals('mobile').nil? ? "" : entry.vals('mobile')[0].force_encoding('UTF-8'),
                       uid: entry.vals('uid').nil? ? "" : entry.vals('uid')[0].force_encoding('UTF-8')
                     })
        end
        result
      rescue
        []
      end
    end
  end
end
